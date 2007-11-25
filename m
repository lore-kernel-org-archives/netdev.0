From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 12/21] r8169: confusion between hardware and IP header
	alignment
Date: Mon, 26 Nov 2007 00:05:24 +0100
Message-ID: <20071125230524.GC21363@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com> <20070629202555.GN3240@electric-eye.fr.zoreil.com> <20071123074549.GE18081@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	bunk@stusta.de
To: Martin Michlmayr <tbm@cyrius.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60983 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757787AbXKYXKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 18:10:49 -0500
Content-Disposition: inline
In-Reply-To: <20071123074549.GE18081@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Michlmayr <tbm@cyrius.com> :
[...]
> I'd like to backport the fix to the 2.6.18 kernel that is in our
> stable release and have a couple of questions:
>  - Does your later patch "align the IP header when there is no DMA
>    constraint" fix any bugs or is it merely an improvement?

It fixes a "it was faster before" problem.

>  - Should I change "align" to 8 for RTL_CFG_1, as it's done in
>    current kernels?

No. RTL_CFG_1 is for the 8168 (slightly different beast).

> I'd like to backport only the changes needed to actually fix the bug
> in order to make sure I won't break any other devices.  The patch
> below works for me but I'd like to hear your opinion about my
> questions above.

If you have 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2 applied, you
want c946b3047205d7e107be16885bbb42ab9f10350a too.

[...]
> Some background: the Thecus N2100 is an ARM based NAS device with two
> 8169 ports. The chips exhibit PCI parity problems so
> dev->broken_parity_status is set on this platform.

I remember it.

If you move from the 8110SB to the 8110SC, you will probably want to apply
65d916d95314566f426cc40ff0f17b754a773b0b

Btw, could you send me a dmesg from a recent kernel ? I'd like to keep a
trace of the XID value for your device.

-- 
Ueimor
