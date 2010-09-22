From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Wed, 22 Sep 2010 17:35:07 +0800
Message-ID: <AANLkTi=iYahjwZt5w53xFsU7fyHr72wXHd9tycwUiNE9@mail.gmail.com>
References: <1284175403-3228-1-git-send-email-xiaosuo@gmail.com>
 <20100912121349.GD22982@redhat.com> <20100914.202023.193706826.davem@davemloft.net>
 <20100915052332.GB25340@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	socketcan@hartkopp.net, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64624 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753265Ab0IVJf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 05:35:28 -0400
Received: by wyf22 with SMTP id 22so284336wyf.19
        for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 02:35:27 -0700 (PDT)
In-Reply-To: <20100915052332.GB25340@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 15, 2010 at 1:23 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
> Hmm, and there's another issue I think I see here:
> destructor_arg now points to a socket.
> What happens if the skb gets queued on an interface for a very long time
> (as can be the case with e.g. tap), and meanwhile
> you try to kill the task that owns the socket, which
> will try to destroy the socket?
>
> Original code handles this by relevant devices orphaning an skb
> if it's queued indefinitely.
>

I don't think the skb_orphan() there is used to destroy the socket in
time, but notify the socket that skbs are sent out and it can send new
skbs.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
