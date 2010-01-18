From: David Miller <davem@davemloft.net>
Subject: Re: phylib: kernel oops on resume with 2.6.33-rc4
Date: Sun, 17 Jan 2010 19:23:53 -0800 (PST)
Message-ID: <20100117.192353.85482728.davem@davemloft.net>
References: <B85A65D85D7EB246BE421B3FB0FBB59301E2025EA9@dbde02.ent.ti.com>
	<20100116223703.GA13190@oksana.dev.rtsoft.ru>
	<B85A65D85D7EB246BE421B3FB0FBB59301E2025EED@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, netdev@vger.kernel.org
To: nsekhar@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37446
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751984Ab0ARDXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 22:23:43 -0500
In-Reply-To: <B85A65D85D7EB246BE421B3FB0FBB59301E2025EED@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nori, Sekhar" <nsekhar@ti.com>
Date: Sun, 17 Jan 2010 13:58:39 +0530

> On Sun, Jan 17, 2010 at 04:07:03, Anton Vorontsov wrote:
>> Hello,
>>
>> On Sat, Jan 16, 2010 at 09:38:34PM +0530, Nori, Sekhar wrote:
>> > Hello all,
>> >
>> > I am hitting a kernel oops when resuming from suspend-to-RAM on 2.6.33-rc4
>> > kernel.
>> >
>> > The MAC is TI DaVinci EMAC and PHY is SMSC LAN8710. However, I also hit the
>> > issue even when using generic PHY driver (CONFIG_SMSC_PHY turned off).
>> >
>> > On reverting commit 541cd3e "phylib: Fix deadlock on resume" which was
>> > introduced in 2.6.33-rc4, the issue doesn't come about. So far, I haven't
>> > figured out how this particular commit is causing the oops. Full oops report
>> > is attached. Appreciate any help in debugging this.
>>
>> It seems phy_start_machine() needlessly reinitialized work
>> struct. This is OK for ucc_geth and gianfar driver because
>> these drivers do not detach PHYs on suspend, but TI davinci
>> does. :-/
>>
>> Can you try the patch down below?
> 
> This seems to have fixed the problem. Thanks! I hope this can be
> included for the next rc. FWIW,
> 
> Reported-and-Tested-by: Sekhar Nori <nsekhar@ti.com>

Anton, please resubmit with your signoff.

Thanks.
