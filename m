From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v6 6/6] samples/bpf: add userspace example for
 prohibiting sockets
Date: Thu, 1 Dec 2016 08:13:52 -0700
Message-ID: <4afe76e2-d1be-4810-0db7-859bcd5c89f3@cumulusnetworks.com>
References: <1480529810-25850-1-git-send-email-dsa@cumulusnetworks.com>
 <1480529810-25850-7-git-send-email-dsa@cumulusnetworks.com>
 <20161201055953.GB42375@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36423 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757534AbcLAPNz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 10:13:55 -0500
Received: by mail-io0-f182.google.com with SMTP id m5so290429507ioe.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 07:13:54 -0800 (PST)
In-Reply-To: <20161201055953.GB42375@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/16 10:59 PM, Alexei Starovoitov wrote:
> On Wed, Nov 30, 2016 at 10:16:50AM -0800, David Ahern wrote:
>> Add examples preventing a process in a cgroup from opening a socket
>> based family, protocol and type.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ...
>> +++ b/samples/bpf/sock_flags_kern.c
>> @@ -0,0 +1,37 @@
>> +#include <uapi/linux/bpf.h>
>> +#include <linux/socket.h>
>> +#include "bpf_helpers.h"
>> +
>> +SEC("cgroup/sock1")
>> +int bpf_prog1(struct bpf_sock *sk)
>> +{
>> +	char fmt[] = "socket: family %d type %d protocol %d\n";
>> +
>> +	bpf_trace_printk(fmt, sizeof(fmt), sk->family, sk->type, sk->protocol);
>> +
>> +	/* block PF_INET6, SOCK_RAW, IPPROTO_ICMPV6 sockets
>> +	 * ie., make ping6 fail
>> +	 */
>> +	if (sk->family == PF_INET6 && sk->type == 3 && sk->protocol == 58)
>> +		return 0;
> 
> why not to use SOCK_RAW and IPPROTO_ICMPV6 instead of constants?

header file hell.
