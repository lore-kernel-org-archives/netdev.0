From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 Wake-on-LAN causes immediate ACPI GPE wakeup
Date: Fri, 6 Oct 2017 02:16:50 +0200
Message-ID: <20171006001649.GA21884@electric-eye.fr.zoreil.com>
References: <CAD8Lp45YVtw48+8jSq6gtu1xA7Rt+qr6vvVZF4AC-QXeCKNj4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-acpi@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Upstreaming Team <linux@endlessm.com>
To: Daniel Drake <drake@endlessm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40310 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdJFAQ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 20:16:58 -0400
Content-Disposition: inline
In-Reply-To: <CAD8Lp45YVtw48+8jSq6gtu1xA7Rt+qr6vvVZF4AC-QXeCKNj4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Drake <drake@endlessm.com> :
[...]
> Also, is there a standard behaviour defined for ethernet drivers
> regarding wake-on-LAN? r8169 appears to enable wake-on-LAN by default
> if it believes the hardware is capable of it,

If so it isn't its designed behavior.

The r8169 driver does not enable specific WoL event source (unicast packet,
link, etc.). It should keep the current settings unless one of those holds:
- explicit wol config from userspace (obviously :o) )
- runtime pm requires different settings to resume. The change should
  be temporary (save before suspend, restore after resume).

The device is supposed to require both an event source + Config1.PMEnable.

A problem may happen if some event source bit is already set while
Config1.PMEnable is not. The driver has been forcing Config1.PMEnable
since 5d06a99f543e734ceb53bbc9e550537be97f0c49. One may thus experience
transition from inconsistent wol settings to enabled ones (if you want
to dig it, check beforehand if Config1.PMEnable is really read-write or
hardwired to 1).

Whatever it seems rather orthogonal with your wake over wifi style instant
resume symptom.

-- 
Ueimor
