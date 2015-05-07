From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 12/21] switchdev: remove old
 switchdev_port_bridge_setlink
Date: Thu, 7 May 2015 17:36:38 +0200
Message-ID: <20150507153637.GB2121@nanopsycho>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
 <1430847297-15728-13-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37584 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbbEGPgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 11:36:41 -0400
Received: by widdi4 with SMTP id di4so64688584wid.0
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 08:36:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430847297-15728-13-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 05, 2015 at 07:34:48PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>New attr-based bridge_setlink can recurse lower devs and recover on err, so
>remove old wrapper.  Also, restore br_setlink back to original and don't
>call into SELF port driver.  rtnetlink.c:bridge_setlink already does a call
>into port driver for SELF.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> include/net/switchdev.h   |   17 -----------------
> net/bridge/br_netlink.c   |   11 +----------
> net/switchdev/switchdev.c |   30 ------------------------------
> 3 files changed, 1 insertion(+), 57 deletions(-)
>
>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>index aa6c370..ce5ceb2 100644
>--- a/include/net/switchdev.h
>+++ b/include/net/switchdev.h
>@@ -122,8 +122,6 @@ int switchdev_port_attr_set(struct net_device *dev,
> 			    struct switchdev_attr *attr);
> int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj);
> int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj);
>-int switchdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
>-			      u16 flags);

I don't understand why you remove this. Would for example bond compile
after this? 
