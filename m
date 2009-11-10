From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Tue, 10 Nov 2009 07:05:23 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911100659470.7059@melkinpaasi.cs.helsinki.fi>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34855 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbZKJFFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 00:05:19 -0500
In-Reply-To: <4AF84BF3.5020302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 Nov 2009, William Allen Simpson wrote:

> This is a significantly revised implementation of an earlier (year-old)
> patch that no longer applies cleanly, with permission of the original
> author (Adam Langley).  That patch was previously reviewed:
> 
>    http://thread.gmane.org/gmane.linux.network/102586
> 
> The principle difference is using a TCP option to carry the cookie nonce,
> instead of a user configured offset in the data.  This is more flexible and
> less subject to user configuration error.  Such a cookie option has been
> suggested for many years, and is also useful without SYN data, allowing
> several related concepts to use the same extension option.
> 
>    "Re: SYN floods (was: does history repeat itself?)", September 9, 1996.
>    http://www.merit.net/mail.archives/nanog/1996-09/msg00235.html
> 
>    "Re: what a new TCP header might look like", May 12, 1998.
>    ftp://ftp.isi.edu/end2end/end2end-interest-1998.mail
> 
> Data structures are carefully composed to require minimal additions.
> For example, the struct tcp_options_received cookie_plus variable fits
> between existing 16-bit and 8-bit variables, requiring no additional
> space (taking alignment into consideration).  There are no additions to
> tcp_request_sock, and only 1 pointer in tcp_sock.
> 
> Allocations have been rearranged to avoid requiring GFP_ATOMIC, with
> only one unavoidable exception in tcp_create_openreq_child(), where the
> tcp_sock itself is created GFP_ATOMIC.
> 
> These functions will also be used in subsequent patches that implement
> additional features.
> 
> Requires:
>   TCPCT part 1a: add request_values parameter for sending SYNACK
>   TCPCT part 1b: TCP_MSS_DEFAULT, TCP_MSS_DESIRED
>   TCPCT part 1c: sysctl_tcp_cookie_size, socket option
> TCP_COOKIE_TRANSACTIONS, functions
>   TCPCT part 1d: generate Responder Cookie
> 
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  include/linux/tcp.h      |   29 ++++-
>  include/net/tcp.h        |   72 +++++++++++++
>  net/ipv4/syncookies.c    |    5 +-
>  net/ipv4/tcp.c           |  127 ++++++++++++++++++++++-
>  net/ipv4/tcp_input.c     |   86 +++++++++++++--
>  net/ipv4/tcp_ipv4.c      |   69 ++++++++++++-
>  net/ipv4/tcp_minisocks.c |   59 ++++++++---
>  net/ipv4/tcp_output.c    |  255
> +++++++++++++++++++++++++++++++++++++++++-----
>  net/ipv6/syncookies.c    |    5 +-
>  net/ipv6/tcp_ipv6.c      |   65 +++++++++++-
>  10 files changed, 701 insertions(+), 71 deletions(-)
> 

One general comment. ...This particular patch still has lots of noise 
which does not belong to the context of this change. ...Please try to 
minimize. Eg., if you don't like sizeof(struct tcphdr) but prefer 
sizeof(*th), you certainly don't have to do it in this particular patch!
...Also some comment changes which certainly are not mandatory nor even 
related.

-- 
 i.
