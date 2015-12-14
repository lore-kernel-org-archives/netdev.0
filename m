From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: add validation for the socket syscall protocol argument
Date: Mon, 14 Dec 2015 10:59:55 -0800
Message-ID: <CAHA+R7MtR-LaE56ByZ3arzFihwp5wn73Kq1i=vxMRHJ3Zo5MhA@mail.gmail.com>
References: <1450109869-23769-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:32968 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368AbbLNS74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 13:59:56 -0500
Received: by qkck189 with SMTP id k189so115154435qkc.0
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 10:59:55 -0800 (PST)
In-Reply-To: <1450109869-23769-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2015 at 8:17 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1098,6 +1098,9 @@ int __sock_create(struct net *net, int family, int type, int protocol,
>                 return -EAFNOSUPPORT;
>         if (type < 0 || type >= SOCK_MAX)
>                 return -EINVAL;
> +       /* upper bound should be tested by per-protocol .create callbacks */
> +       if (protocol < 0)
> +               return -EINVAL;

Why? At least  bt_sock_create() and  netlink_create() do both upper bound
and lower bound checks.
