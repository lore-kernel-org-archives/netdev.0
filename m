From: Ahmed Tamrawi <ahmedtamrawi@gmail.com>
Subject: mutex_unlock is missed in function (drm_crtc_init) in file (linux-3.13/drivers/gpu/drm/drm_crtc.c)
Date: Wed, 5 Feb 2014 11:23:44 -0600
Message-ID: <CAFZT-j+u9MMeQXNiozhAn9dpSjivEnadevpKk7LtXLVyTGqcsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f43.google.com ([209.85.212.43]:56054 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbaBERXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 12:23:45 -0500
Received: by mail-vb0-f43.google.com with SMTP id p5so530891vbn.30
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 09:23:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug Report Filed: https://bugzilla.kernel.org/show_bug.cgi?id=70081
Linux Version [3.13]
Configuration: Default configuration for x86

In function (drm_crtc_init) in file (linux-3.13/drivers/gpu/drm/drm_crtc.c):

The structure (crtc->mutex) gets successfully locked at line (636) by
(drm_modeset_lock_all(dev)), but it is not unlocked before line (637)
where the structure is reinitialized. After line (637) the
re-initialized structure gets locked at (638) and unlocked at line
(650) by (drm_modeset_unlock_all(dev)).

A possible solution is to call (drm_modeset_unlock_all(dev)) before
the re-initialization line (637).


Thanks,
Ahmed
