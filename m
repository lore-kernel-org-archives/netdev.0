From: hayeswang <hayeswang@realtek.com>
Subject: RE: Re: RTL 8169  linux driver question
Date: Wed, 28 Nov 2012 10:32:12 +0800
Message-ID: <69AF1A3D48D2421CBA361D822F8D8894@realtek.com.tw>
References: <50AFC971.7010103@free.fr> <50AFCB1D.8080002@free.fr> <AE90C24D6B3A694183C094C60CF0A2F6026B70BD@saturn3.aculab.com> <20121127224605.GA10228@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: =?iso-8859-1?Q?'St=E9phane_ANCELOT'?= <sancelot@free.fr>,
	<netdev@vger.kernel.org>, <sancelot@numalliance.com>,
	'nic_swsd' <nic_swsd@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'David Laight' <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:56260 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763Ab2K1Cck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 21:32:40 -0500
In-Reply-To: <20121127224605.GA10228@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> Something like the patch below against net-next could help once I will
> have tested it.
> 
> I completely guessed the Tx usec scale factor at gigabit 
> speed (125 us, 
> 100 us, disabled, who knows ?) and I have no idea which 
> specific chipsets
> it should work with.
> 
> Hayes, may I expect some hindsight regarding:
> 1 - the availability of the IntrMitigate (0xe2) register through the
>     8169, 8168 and 810x line of chipsets

8169, 8168, and 8136(810x) serial chipsets support it.

> 2 - the Tx timer unit at gigabit speed

The unit of the timer depneds on both the speed and the setting of CPlusCmd
(0xe0) bit 1 and bit 0.

For 8169
bit[1:0] \ speed	1000M		100M		10M
0 0		320ns		2.56us		40.96us
0 1		2.56us		20.48us		327.7us
1 0		5.12us		40.96us		655.4us
1 1		10.24us		81.92us		1.31ms

For the other
bit[1:0] \ speed	1000M		100M		10M
0 0		5us		2.56us		40.96us
0 1		40us		20.48us		327.7us
1 0		80us		40.96us		655.4us
1 1		160us		81.92us		1.31ms

 
Best Regards,
Hayes
