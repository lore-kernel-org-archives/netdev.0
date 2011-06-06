From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Mon, 06 Jun 2011 15:18:12 +0200
Message-ID: <1307366292.3098.17.camel@edumazet-laptop>
References: <4DE93422.3070000@ahsoftware.de>
	 <20110606111507.GA1000@hmsreliant.think-freely.org>
	 <4DECBEA3.6070408@ahsoftware.de> <1307362358.3098.6.camel@edumazet-laptop>
	 <4DECCCC0.70905@ahsoftware.de>
	 <20110606131309.GB1000@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Holler <holler@ahsoftware.de>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47537 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756155Ab1FFNSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 09:18:16 -0400
In-Reply-To: <20110606131309.GB1000@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 09:13 -0400, Neil Horman a =C3=A9crit :

> Ok, this makes sense to me now, thanks.  The change to the dst inital=
ization to
> mark our fake routing table as read only means we need a cow_metrics =
method to
> copy the metrics before we we can compete the dst_metric_set in br_ch=
ange_mtu.
> Thats fine, but given that its really a fake routing table with only =
one dst
> entry which (I think) is only written under the rtnl lock, why not ju=
st modify
> the dst_init_metrics call so that its not marked as read-only?

It _is_ read-only, its even a "const", so if you do that you'll trap if
kernel const pages are RO

Please check commit 0972ddb237 for a proper way to deal with this.



