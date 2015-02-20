From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next RFC 5/5] rocker: explicitly set SW ageing for
 rocker
Date: Fri, 20 Feb 2015 10:46:06 +0100
Message-ID: <20150220092518.GA2008@nanopsycho.orion>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
 <1424416195-19098-6-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, vbandaru@broadcom.com,
	siva.mannem.lnx@gmail.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:41847 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbbBTJqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 04:46:09 -0500
Received: by wevm14 with SMTP id m14so4548182wev.8
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 01:46:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1424416195-19098-6-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 20, 2015 at 08:09:55AM CET, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Rocker (for now) will rely on SW (bridge) ageing.  Other drivers/devices may
>wish to set NTF_EXT_AGED to turn off SW (bridge) ageing.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> drivers/net/ethernet/rocker/rocker.c |    9 +++++----
> 1 file changed, 5 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index 34389b6a..7b55934 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -3026,10 +3026,11 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
> 		container_of(work, struct rocker_fdb_learn_work, work);
> 	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
> 	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
>-	struct netdev_switch_notifier_fdb_info info;
>-
>-	info.addr = lw->addr;
>-	info.vid = lw->vid;
>+	struct netdev_switch_notifier_fdb_info info = {
>+		.addr = lw->addr,
>+		.vid = lw->vid,
>+		.ntf_flags = NTF_EXT_LEARNED,
>+	};

I think that this patch should be before "bridge: call external learn add
if adding FDB entry with NTF_EXT_LEARNED set" in order to not break
functionality during bisect.

> 
> 	if (learned && removing)
> 		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL,
>-- 
>1.7.10.4
>
