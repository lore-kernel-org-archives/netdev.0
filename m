From: Bastien Nocera <hadess@hadess.net>
Subject: Re: [PATCH 06/22] staging: rtl8723bs: Fix various errors in
 os_dep/ioctl_cfg80211.c
Date: Sun, 09 Apr 2017 17:28:18 +0200
Message-ID: <1491751698.10783.18.camel@hadess.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
         <20170408160745.14328-7-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, jes.sorensen@gmail.com
To: Larry Finger <Larry.Finger@lwfinger.net>,
        gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:45102 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752262AbdDIP2Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 11:28:25 -0400
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net [217.70.183.200])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 5BBE9486369
        for <netdev@vger.kernel.org>; Sun,  9 Apr 2017 17:28:24 +0200 (CEST)
In-Reply-To: <20170408160745.14328-7-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 11:07 -0500, Larry Finger wrote:
> Smatch lists the following:
> 
>   CHECK   drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:470
> rtw_cfg80211_ibss_indicate_connect() error: we previously assumed
> 'scanned' could be null (see line 466)
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:942
> rtw_cfg80211_set_encryption() warn: inconsistent indenting
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:955
> rtw_cfg80211_set_encryption() error: buffer overflow 'psecuritypriv-
> >dot11DefKey' 4 <= 4
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:1017
> rtw_cfg80211_set_encryption() error: buffer overflow 'padapter-
> >securitypriv.dot118021XGrpKey' 5 <= 5
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:1216
> cfg80211_rtw_set_default_key() warn: inconsistent indenting
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2498
> rtw_cfg80211_monitor_if_xmit_entry() error: we previously assumed
> 'skb' could be null (see line 2495)
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2850
> cfg80211_rtw_start_ap() warn: if statement not indented
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2860
> cfg80211_rtw_start_ap() warn: if statement not indented
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:3417
> rtw_cfg80211_preinit_wiphy() warn: inconsistent indenting
> drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:3547
> rtw_wdev_alloc() info: ignoring unreachable code.
> 
> The indenting warnings were fixed by simple white space changes.
> 
> The section where 'scanned' could be null required an immediate exit
> from
> the routine at that point. A similar fix was required where 'skb'
> could be null.
> 
> The two buffer overflow errors were caused by off-by-one errors.
> While
> locating these problems, another one was found in
> os_dep/ioctl_linux.c.

Could you please split those up into patches that fix one kind of
problem? Makes it easier to review.
