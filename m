From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 7 May 2008 17:16:08 -0700
Message-ID: <d1c2719f0805071716r1aa5ca71tc0da19296e0248e@mail.gmail.com>
References: <d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
	 <20080506.212829.213490532.davem@davemloft.net>
	 <d1c2719f0805071154t20004e9drecd3d9b7b9b3470c@mail.gmail.com>
	 <20080507.142013.219220793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:5569 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbYEHAQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 20:16:15 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m480GBsV006759
	for <netdev@vger.kernel.org>; Thu, 8 May 2008 01:16:11 +0100
Received: from hs-out-0708.google.com (hsl4.prod.google.com [10.44.12.4])
	by zps75.corp.google.com with ESMTP id m480G9sY018359
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 17:16:09 -0700
Received: by hs-out-0708.google.com with SMTP id 4so335507hsl.1
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 17:16:09 -0700 (PDT)
In-Reply-To: <20080507.142013.219220793.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2008 at 2:20 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jerry Chu" <hkchu@google.com>
>  Date: Wed, 7 May 2008 11:54:01 -0700
>
>
>  > This is one of many things about skb that I still don't completely understand.
>  > Why in tcp_transmit_skb() we'll have to pskb_copy() if skb_cloned()?
>
>  The other clone holder owns the packet header area.  All packets on
>  the retransmit queue of TCP are headerless.  The call sites down
>  into the device add the headers.
>
>  Therefore we cannot have two paths modifying the headers at the same
>  time.

Oh I see. I think I confused pskb_copy() with skb_copy() and kept thinking
why do we need to copy the whole thing...

>
>
>  > Can't we clone a skb mulitple times? Is it due to some special optimization
>  > from skb->fclone stuff... that imposes this restriction?
>
>  No, it has nothing to do with fclone.  It has to do with what instance
>  owns the packet header area in front of the user's TCP data.

Thanks for explaining.

Jerry

>
