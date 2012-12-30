From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] team: implement carrier change
Date: Sun, 30 Dec 2012 09:50:42 +0100
Message-ID: <20121230085042.GA1575@minipsycho.orion>
References: <1356831061-1483-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:51426 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab2L3Iuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 03:50:50 -0500
Received: by mail-ee0-f41.google.com with SMTP id d41so5918202eek.28
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 00:50:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1356831061-1483-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Dec 30, 2012 at 02:31:01AM CET, fbl@redhat.com wrote:
>The user space teamd daemon may need to control the
>master's carrier state depending on the selected mode.
>
>Signed-off-by: Flavio Leitner <fbl@redhat.com>
>---
> drivers/net/team/team.c | 10 ++++++++++
> 1 file changed, 10 insertions(+)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index f711039..14cb843 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1708,6 +1708,15 @@ static netdev_features_t team_fix_features(struct net_device *dev,
> 	return features;
> }
> 
>+static int team_change_carrier(struct net_device *dev, bool new_carrier)
>+{
>+	if (new_carrier)
>+		netif_carrier_on(dev);
>+	else
>+		netif_carrier_off(dev);
>+	return 0;
>+}
>+
> static const struct net_device_ops team_netdev_ops = {
> 	.ndo_init		= team_init,
> 	.ndo_uninit		= team_uninit,
>@@ -1730,6 +1739,7 @@ static const struct net_device_ops team_netdev_ops = {
> 	.ndo_add_slave		= team_add_slave,
> 	.ndo_del_slave		= team_del_slave,
> 	.ndo_fix_features	= team_fix_features,
>+	.ndo_change_carrier     = team_change_carrier,
> };
> 
> /***********************
>-- 
>1.8.0.1

Acked-by: Jiri Pirko <jiri@resnulli.us>
>
