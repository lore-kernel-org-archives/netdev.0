From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Mon, 23 Feb 2015 11:51:51 -0800
Message-ID: <1424721111.5565.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	 <1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	 <20150223205633.7fbd08d4@halley>
	 <1424718636.5565.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHsH6Guk-8DK1iyth4ZDSikjb_-xjrsBTRa-hp1nWaavvQ0uuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:64576 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbbBWTvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 14:51:54 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so21062292igb.3
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 11:51:53 -0800 (PST)
In-Reply-To: <CAHsH6Guk-8DK1iyth4ZDSikjb_-xjrsBTRa-hp1nWaavvQ0uuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-23 at 21:25 +0200, Eyal Birger wrote:

> The original commit introducing dropcount for af_packet
> (see http://marc.info/?l=linux-netdev&m=125450261121971) also claimed
> the proper location would in fact be skb->cb[]. However, it was also
> claimed that
> skb->cb[] is all used up.
> 
> Things are even more complicated now as dropcount became a socket
> level feature and skb->cb[] is handled differently in each protocol family.

I did a check, and all current sock_recv_ts_and_drops() users have room
in skb->cb[] to store dropcount, say at the beginning of the array.

I have no big opinion here, but intuitively dropcount has a very short
lifetime and skb->cb[] seems appropriate.
