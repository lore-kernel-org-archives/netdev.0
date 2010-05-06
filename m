From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH (v2)] bridge: update sysfs link names if port device
 names have changed
Date: Thu, 6 May 2010 12:11:07 -0700
Message-ID: <20100506121107.1868ad07@nehalam>
References: <4BE30B3D.9000600@simon.arlott.org.uk>
	<4BE31218.6010709@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41415 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756027Ab0EFTL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 15:11:27 -0400
In-Reply-To: <4BE31218.6010709@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 May 2010 20:01:44 +0100
Simon Arlott <simon@fire.lp0.eu> wrote:

> +
> +	case NETDEV_CHANGENAME:
> +		err = br_sysfs_renameif(p);
> +		if (err)
> +			return NOTIFY_BAD;
> +		break;

I think you want:
 if (err)
	return notifier_from_errno(err);


+	err = sysfs_rename_link(br->ifobj, &p->kobj,
+		p->sysfs_name, p->dev->name);
+	if (err) {
+		printk(KERN_ERR "%s: unable to rename sysfs link %s to %s (%d)",
+			br->dev->name, p->sysfs_name, p->dev->name, err);

This should not be KERN_ERR but KERN_NOTICE, and use new wrapper macros.

	if (err)
		netdev_notice(br->dev, "unable to rename sysfs link %s to %s".
			 p->sysfs_name, p->dev->name, err)
