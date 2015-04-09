From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Thu, 09 Apr 2015 17:22:39 +0200
Message-ID: <5526993F.1010304@free.fr>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Daniel Mack <daniel@zonque.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:19313 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755736AbbDIPWq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 11:22:46 -0400
In-Reply-To: <55268EF3.7050301@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason wrote:

> Daniel Mack wrote:
>
>> My suggestion is to dump the entire register set when
>> at803x_config_init() is entered and again when it's left. Then try to
>> find the differences and see if you can bring the PHY into the needed
>> mode through the existing configuration hooks in the kernel.
>
> [    0.685330] IDX= 1 796d != 7949
> [    0.688490] IDX= 5 c1e1 != 0000
> [    0.691647] IDX= 6 000f != 0004
> [    0.694803] IDX=10 3800 != 0000
> [    0.697960] IDX=17 bc10 != 0012
> [    0.701115] IDX=19 7400 != 0000
> [    0.704271] IDX=27 060e != 0600
>
> Hmmm, didn't expect so many differences. I'll have to take a closer look.

For the record, I dumped the PHY registers
A) upon entering phy_init_hw
B) before leaving phy_init_hw (thus right after at803x_config_init)

IDX 1: b2 LINK STATUS, b5 AUTO-NEGOTIATION COMPLETE
=> Difference in status bits, seems reasonable

IDX 5: Link partner ability (base page)
=> seems reasonable (no partner yet?)

IDX 6: Auto-Negotiation Expansion
=> seems reasonable (no partner yet?)

IDX 10: 1000 BASE-T Status (HW reset = SW reset = 0)
(ALSO: Contents of this register clear after a read operation has occurred.)
=> Looks like my own read cleared it

IDX 17: PHY-Specific Status
b1 = "POLARITY (real time)"?
=> Difference in status bits, seems reasonable? (

IDX 19: Interrupt Status
=> Looks like some interrupt requests might have been discarded?

IDX 27: This register is undocumented

Nothing looks suspicious, except maybe the Interrupt Status?

Is speed auto-negotiation supposed to be complete when phy_init_hw exits?

Regards.
