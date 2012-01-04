From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Enable suspend when device is idle from boot.
Date: Wed, 4 Jan 2012 23:07:14 +0100
Message-ID: <20120104220714.GA31684@electric-eye.fr.zoreil.com>
References: <1325183594-8947-1-git-send-email-tbroch@chromium.org> <20111230.172211.188260740088628815.davem@davemloft.net> <20111231121704.GA9842@electric-eye.fr.zoreil.com> <20120103233046.GD8563@electric-eye.fr.zoreil.com> <CAOesGMip7hRsGmRuQ7PmDReKp08awsrq_0R+0BouLEisyMpMGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tbroch@chromium.org, David Miller <davem@davemloft.net>,
	nic_swsd@realtek.com, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59852 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757056Ab2ADWQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 17:16:28 -0500
Content-Disposition: inline
In-Reply-To: <CAOesGMip7hRsGmRuQ7PmDReKp08awsrq_0R+0BouLEisyMpMGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olof Johansson <olof@lixom.net> :
> On Tue, Jan 3, 2012 at 3:30 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> > Francois Romieu <romieu@fr.zoreil.com> :
> > [...]
> >> The description of the patch implies that the initial power management
> >> state is not right. I would be more inclined to set it correctly when
> >> the device goes up instead of checking repeatedly for a loss of sync
> >> through rtl8169_runtime_idle. Todd, any comment ?
> >
> > ... which could be as simple as (completely untested) :
> 
> That change is just to the code path of open(), which means that for
> the power savings to kick in, you have to bring the interface up. The
> point of the original patch is to check even if the interface has
> never been touched.

Fair enough.

If so the original patch should not be needed as the driver core is
supposed to invoke the idle callback after probe (aka rtl8169_init_one).
After probe the device is in TxDescArray == 0 state and rtl8169_runtime_idle
returns 0. pm_runtime_suspend should thus be called [*]... I must have
missed something. :o/

[*] Not sure if it always imply a transition to D3 though.

> Perhaps call check_link_status at the end if init_one instead to
> activate pm then ?

It should not be needed, see above.

Moreover one should not care for the link status until the device is
brought up. It may seem a bit counterintuitive but the device and its
PHY are tightly coupled here. You do not manage them separately.

You should forget it anyway: PHY init happens late in the r8169 driver
and it can not be done sooner as it sometimes depends on firmware loading.

-- 
Ueimor
