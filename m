From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Thu, 9 Oct 2014 10:21:12 +0200
Message-ID: <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru>
	<2326963.udog5tteBt@eisbaer>
	<542A8092.9090602@broadcom.com>
	<1527190.sqFmD6XRNJ@eisbaer>
	<54363ED0.605@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	Michael Tokarev <mjt@tls.msk.ru>,
	Seth Forshee <seth.forshee@canonical.com>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:41903 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbaJIIVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 04:21:13 -0400
In-Reply-To: <54363ED0.605@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 October 2014 09:52, Arend van Spriel <arend@broadcom.com> wrote:
> I have been staring at differences brcmsmac and our internal driver (which
> wl is derived from as well). Would you be able to make an mmiotrace loading
> wl and brcmsmac.

Arend,

As you noticed earlier, this is a WiFi card with BT. I've checked
siutils.c from SDK 7.14.43.7 (got it from Netgear R8000) and it has
three BCM4313 workarounds:


1) si_doattach
SI_MSG(("Applying 4313 WARs\n"));
si_pmu_chipcontrol(sih, 0, CCTRL_4313_12MA_LED_DRIVE,
CCTRL_4313_12MA_LED_DRIVE);

It's already implemented in bcma, see driver_chipcommon_pmu.c


2) si_epa_4313war
/* EPA Fix */
W_REG(sii->osh, &cc->gpiocontrol,
R_REG(sii->osh, &cc->gpiocontrol) | GPIO_CTRL_EPA_EN_MASK);

This is what you already implement in ai_epa_4313war


3) si_pmu_synth_pwrsw_4313_war
I don't think it's implemented.


4) si_btcombo_p250_4313_war
I also don't think it's implemented


The last one (si_btcombo_p250_4313_war) looks promising, the comment
above the function says:
/** WL/BT control for 4313 btcombo boards >= P250 */
I guess you need to re-implement this function and call it somewhere
in brcmsmac.
