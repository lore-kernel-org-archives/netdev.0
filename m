From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v6 6/6] samples/bpf: add userspace example for
 prohibiting sockets
Date: Wed, 30 Nov 2016 21:59:55 -0800
Message-ID: <20161201055953.GB42375@ast-mbp.thefacebook.com>
References: <1480529810-25850-1-git-send-email-dsa@cumulusnetworks.com>
 <1480529810-25850-7-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35684 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758542AbcLAGAC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 01:00:02 -0500
Received: by mail-pf0-f193.google.com with SMTP id i88so1939951pfk.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:00:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480529810-25850-7-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 10:16:50AM -0800, David Ahern wrote:
> Add examples preventing a process in a cgroup from opening a socket
> based family, protocol and type.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
...
> +++ b/samples/bpf/sock_flags_kern.c
> @@ -0,0 +1,37 @@
> +#include <uapi/linux/bpf.h>
> +#include <linux/socket.h>
> +#include "bpf_helpers.h"
> +
> +SEC("cgroup/sock1")
> +int bpf_prog1(struct bpf_sock *sk)
> +{
> +	char fmt[] = "socket: family %d type %d protocol %d\n";
> +
> +	bpf_trace_printk(fmt, sizeof(fmt), sk->family, sk->type, sk->protocol);
> +
> +	/* block PF_INET6, SOCK_RAW, IPPROTO_ICMPV6 sockets
> +	 * ie., make ping6 fail
> +	 */
> +	if (sk->family == PF_INET6 && sk->type == 3 && sk->protocol == 58)
> +		return 0;

why not to use SOCK_RAW and IPPROTO_ICMPV6 instead of constants?

Thanks for the test!
