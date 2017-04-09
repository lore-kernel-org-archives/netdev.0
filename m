From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH net-next 0/1 v2] skbuff: Extend gso_type to unsigned int.
Date: Sun, 9 Apr 2017 19:07:24 +0300
Message-ID: <20170409160724.GA28980@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34035 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752342AbdDIQH2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 12:07:28 -0400
Received: by mail-wr0-f195.google.com with SMTP id u18so18173743wrc.1
        for <netdev@vger.kernel.org>; Sun, 09 Apr 2017 09:07:28 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  struct skb_shared_info {
> +	unsigned short	_unused;
>  	unsigned char	nr_frags;

This makes _all_ fields to be accessed with offset, but if you move
padding down, at least ->nr_frags will enjoy clean and simple [R64]
addressing.

On allyesconfig-ish kernel:

	before:	+542 = 720-178
	 after:	-158 =  53-211 (negative, because 16-bit field became 32-bit)

You may want to add configurable redzone there instead of padding
if that what you want. 2 bytes is nothing.
