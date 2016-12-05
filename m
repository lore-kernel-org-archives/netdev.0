From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v6 6/6] samples/bpf: add userspace example for
 prohibiting sockets
Date: Mon, 5 Dec 2016 10:51:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0234BBD@AcuExch.aculab.com>
References: <1480529810-25850-1-git-send-email-dsa@cumulusnetworks.com>
 <1480529810-25850-7-git-send-email-dsa@cumulusnetworks.com>
 <20161201055953.GB42375@ast-mbp.thefacebook.com>
 <4afe76e2-d1be-4810-0db7-859bcd5c89f3@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "daniel@zonque.org" <daniel@zonque.org>, "ast@fb.com" <ast@fb.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "maheshb@google.com" <maheshb@google.com>,
        "tgraf@suug.ch" <tgraf@suug.ch>
To: 'David Ahern' <dsa@cumulusnetworks.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:54937 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751134AbcLEKvq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 05:51:46 -0500
In-Reply-To: <4afe76e2-d1be-4810-0db7-859bcd5c89f3@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern
> Sent: 01 December 2016 15:14
> On 11/30/16 10:59 PM, Alexei Starovoitov wrote:
> > On Wed, Nov 30, 2016 at 10:16:50AM -0800, David Ahern wrote:
> >> Add examples preventing a process in a cgroup from opening a socket
> >> based family, protocol and type.
> >>
> >> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> > ...
> >> +++ b/samples/bpf/sock_flags_kern.c
> >> @@ -0,0 +1,37 @@
> >> +#include <uapi/linux/bpf.h>
> >> +#include <linux/socket.h>
> >> +#include "bpf_helpers.h"
> >> +
> >> +SEC("cgroup/sock1")
> >> +int bpf_prog1(struct bpf_sock *sk)
> >> +{
> >> +	char fmt[] = "socket: family %d type %d protocol %d\n";
> >> +
> >> +	bpf_trace_printk(fmt, sizeof(fmt), sk->family, sk->type, sk->protocol);
> >> +
> >> +	/* block PF_INET6, SOCK_RAW, IPPROTO_ICMPV6 sockets
> >> +	 * ie., make ping6 fail
> >> +	 */
> >> +	if (sk->family == PF_INET6 && sk->type == 3 && sk->protocol == 58)
> >> +		return 0;
> >
> > why not to use SOCK_RAW and IPPROTO_ICMPV6 instead of constants?
> 
> header file hell.

You can at least improve the comment.
Or add:
#ifndef SOCK_RAW
#define SPCK_RAW 3
#endif
(etc) at the top of the file.

	David
