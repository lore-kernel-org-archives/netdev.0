From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] team: block mtu change before it happens
 via NETDEV_PRECHANGEMTU
Date: Thu, 16 Jan 2014 08:18:14 +0100
Message-ID: <20140116071814.GC2815@minipsycho.orion>
References: <1389826939-20691-1-git-send-email-vfalico@redhat.com>
 <1389826939-20691-2-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:42621 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaAPHSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 02:18:18 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so1295050eei.7
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 23:18:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1389826939-20691-2-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 16, 2014 at 12:02:19AM CET, vfalico@redhat.com wrote:
>Now it catches the NETDEV_CHANGEMTU notification, which is signaled after
>the actual change happened on the device, and returns NOTIFY_BAD, so that
>the change on the device is reverted.
>
>This might be quite costly and messy, so use the new NETDEV_PRECHANGEMTU to
>catch the MTU change before the actual change happens and signal that it's
>forbidden to do it.
>
>CC: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
> drivers/net/team/team.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index b75ae5b..dff24e3 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -2851,7 +2851,7 @@ static int team_device_event(struct notifier_block *unused,
> 	case NETDEV_FEAT_CHANGE:
> 		team_compute_features(port->team);
> 		break;
>-	case NETDEV_CHANGEMTU:
>+	case NETDEV_PRECHANGEMTU:
> 		/* Forbid to change mtu of underlaying device */
> 		return NOTIFY_BAD;
> 	case NETDEV_PRE_TYPE_CHANGE:
>-- 
>1.8.4
>

Acked-by: Jiri Pirko <jiri@resnulli.us>
