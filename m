From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] team: unsyc the devices addresses when port is removed
Date: Thu, 7 Mar 2013 19:30:00 +0100
Message-ID: <20130307183000.GA1532@minipsycho.orion>
References: <1362679165-31203-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:36910 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152Ab3CGSaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 13:30:05 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so606987eei.35
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 10:30:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1362679165-31203-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 07, 2013 at 06:59:25PM CET, vyasevic@redhat.com wrote:
>When a team port is removed, unsync all devices addresses that may have
>been synched to the port devices.


This is looking good to me. Thanks for spotting this bug.

Acked-by: Jiri Pirko <jiri@resnulli.us>

>
>CC: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>---
> drivers/net/team/team.c |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 05c5efe..bf34192 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1138,6 +1138,8 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
> 	netdev_upper_dev_unlink(port_dev, dev);
> 	team_port_disable_netpoll(port);
> 	vlan_vids_del_by_dev(port_dev, dev);
>+	dev_uc_unsync(port_dev, dev);
>+	dev_mc_unsync(port_dev, dev);
> 	dev_close(port_dev);
> 	team_port_leave(team, port);
> 
>-- 
>1.7.7.6
>
