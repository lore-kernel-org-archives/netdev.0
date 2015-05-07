From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 12/21] switchdev: remove old
 switchdev_port_bridge_setlink
Date: Thu, 7 May 2015 17:33:40 +0200
Message-ID: <20150507153340.GA2121@nanopsycho>
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
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33305 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbbEGPdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 11:33:44 -0400
Received: by wgin8 with SMTP id n8so47446017wgi.0
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 08:33:43 -0700 (PDT)
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

Although the patch description does not say so, this patch really
removes "ndo_dflt_switchdev_port_bridge_setlink".

....


> 	}
> 
>-	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
>-		/* set bridge attributes in hardware if supported
>-		 */
>-		ret_offload = switchdev_port_bridge_setlink(dev, nlh, flags);
>-		if (ret_offload && ret_offload != -EOPNOTSUPP)
>-			br_warn(p->br, "error setting attrs on port %u(%s)\n",
>-				(unsigned int)p->port_no, p->dev->name);
>-	}
>-

Also, I think that this hunk should be as a separate patch as I really
don't see direct relation with the rest of the patch.
