From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug] skb truesize does not update properly in many place
Date: Fri, 14 Oct 2011 07:51:57 +0200
Message-ID: <1318571517.2533.80.camel@edumazet-laptop>
References: <1318570381-4731-1-git-send-email-roy.qing.li@gmail.com>
	 <1318571313.2533.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57865 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830Ab1JNFwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 01:52:04 -0400
Received: by wyg34 with SMTP id 34so2619755wyg.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 22:52:03 -0700 (PDT)
In-Reply-To: <1318571313.2533.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 07:48 +0200, Eric Dumazet a =C3=A9cr=
it :

> I am now focusing in the TCP pruning effect, that we can see with WIF=
I
> drivers (and also with drivers using a full PAGE to store a 1500 byte
> tcp frame), when a single packet loss is happening on a session with
> large RTT.
>=20

Here is what I am currently testing :

When one SKB has to be queued in out_of_order_queue,
possibly for a long time, try to reduce its truesize (by using
skb_copy_expand()) if skb->truesize is larger than
2*SKB_TRUESIZE(skb->len)

It seems to work very well, and should not happen in fast path.

Stay tuned
