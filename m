From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Wed, 20 Apr 2011 21:13:16 +0200
Message-ID: <20110420191316.GA18805@electric-eye.fr.zoreil.com>
References: <4DAC7001.9060800@hotmail.com> <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	nic_swsd@realtek.com
To: John Lumby <johnlumby@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52418 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078Ab1DTTV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:21:29 -0400
Content-Disposition: inline
In-Reply-To: <4DACAC7E.4070400@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Lumby <johnlumby@hotmail.com> :
[...]
> I've  verified that on my 8168c by simulating an allocation failure
> on 15 out of every 16 rx-Interrupts  (unhooking the current skb and
> then simply not allocating a new skb and not giving the
> corresponding descriptor to the asic) and everything works just
> fine,  with just a slight drop in throughput (down to 987 Mbits/sec,
> still well ahead of the always-copy).

Did your testing account for some memory pressure ?

> So do we really need to be that concerned about occasional
> allocation failure?

See $search_engine +r8169 high order memory allocation failure.

> And if someone is that concerned,   then,   with my proposal,  they
> can leave the rx_copybreak at its default of 16383,   when every
> packet is copied anyway.     (My patch takes a slightly different
> approach if the allocation of the new skb fails  -   current 2.6.39
> drops the packet,   I would propose to unhook and retain the
> descriptor because I can replenish later  -  but that is also
> debatable).     Also that's why I favour making the rx ring size
> configurable.

Why don't you send the patch through the mailing list ?

(hint, hint)

> On 04/18/11 14:21, Francois Romieu wrote:
> >Short answer: it's mostly related to CVE-2009-4537 (see git log).
> 
> I understand the need to make the rx_buf_size 16383 to defeat the
> DOS attacker,   no suggestion to alter that.     I'm just not sure I
> see why that has to imply the always_copy.

Because of high-order memory allocation failure under memory pressure and
memory wastage. Btw several 816x have limited jumbo frames abilities.

-- 
Ueimor
