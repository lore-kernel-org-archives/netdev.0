From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] r8169: Enable suspend when device is idle from boot.
Date: Wed, 4 Jan 2012 10:01:44 -0800
Message-ID: <CAOesGMip7hRsGmRuQ7PmDReKp08awsrq_0R+0BouLEisyMpMGg@mail.gmail.com>
References: <1325183594-8947-1-git-send-email-tbroch@chromium.org>
	<20111230.172211.188260740088628815.davem@davemloft.net>
	<20111231121704.GA9842@electric-eye.fr.zoreil.com>
	<20120103233046.GD8563@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: tbroch@chromium.org, David Miller <davem@davemloft.net>,
	nic_swsd@realtek.com, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45699 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab2ADSBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 13:01:46 -0500
Received: by werm1 with SMTP id m1so8748114wer.19
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 10:01:45 -0800 (PST)
In-Reply-To: <20120103233046.GD8563@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2012 at 3:30 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
>> The description of the patch implies that the initial power management
>> state is not right. I would be more inclined to set it correctly when
>> the device goes up instead of checking repeatedly for a loss of sync
>> through rtl8169_runtime_idle. Todd, any comment ?
>
> ... which could be as simple as (completely untested) :

That change is just to the code path of open(), which means that for
the power savings to kick in, you have to bring the interface up. The
point of the original patch is to check even if the interface has
never been touched.

Perhaps call check_link_status at the end if init_one instead to
activate pm then?


-Olof
