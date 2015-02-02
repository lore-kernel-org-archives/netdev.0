From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 01/18] netlink: make the check for "send from tx_ring"
 deterministic
Date: Mon, 02 Feb 2015 16:14:16 +0300
Message-ID: <54CF7828.6040605@cogentembedded.com>
References: <20150131035513.GK29656@ZenIV.linux.org.uk> <1422863977-17668-1-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:62367 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932156AbbBBNOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 08:14:17 -0500
Received: by mail-la0-f44.google.com with SMTP id s18so40683588lam.3
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 05:14:15 -0800 (PST)
In-Reply-To: <1422863977-17668-1-git-send-email-viro@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/2/2015 10:59 AM, Al Viro wrote:

> From: Al Viro <viro@zeniv.linux.org.uk>

> As it is, zero msg_iovlen means that the first iovec in the kernel
> array of iovecs is left uninitialized, so checking if its ->iov_base
> is NULL is random.  Since the real users of that thing are doing
> sendto(fd, NULL, 0, ...), they are getting msg_iovlen = 1 and
> msg_iov[0] = {NULL, 0}, which is what this test is trying to catch.
> As suggested by davem, let's just check that msg_iovlen was 1 and
> msg_iov[0].iov_base was NULL - _that_ is well-defined and it catches
> what we want to catch.

> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>   net/netlink/af_netlink.c | 4 ++++
>   1 file changed, 4 insertions(+)

> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index a36777b..af51d58 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -2298,7 +2298,11 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
>   			goto out;
>   	}
>
> +        /* It's a really convoluted way for userland to ask for mmaped
> +	 * sendmsg(), but that's what we've got...  */

    Hmm, not sure why DaveM hasn't commented on this broken comment formatting 
(perhaps he was going to fix it while applying?). The preferred comment style 
in the networking code is:

/* bla
  * bla
  */

WBR, Sergei
