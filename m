From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
Date: Tue, 31 Mar 2015 00:22:59 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC35067FAA25@ORSMSX101.amr.corp.intel.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
 <1427704836-8776-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: "sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16799 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524AbbCaAXC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 20:23:02 -0400
In-Reply-To: <1427704836-8776-3-git-send-email-sfeldma@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of sfeldma@gmail.com
>Sent: Monday, March 30, 2015 1:40 AM
>To: netdev@vger.kernel.org
>Cc: jiri@resnulli.us; roopa@cumulusnetworks.com; linux@roeck-us.net;
>f.fainelli@gmail.com
>Subject: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
>
>From: Scott Feldman <sfeldma@gmail.com>
>
[cut]
>
> int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
> {
>-	return -EOPNOTSUPP;
>+	struct swdev_attr prev = *attr;
>+	int err, get_err;
>+
>+	get_err = swdev_port_attr_get(dev, &prev);
>+
>+	err = _swdev_port_attr_set(dev, attr);
>+	if (err && !get_err && !(attr->flags & SWDEV_ATTR_F_NO_RECOVER))
>+		/* Some err on set: revert to previous value */
>+		_swdev_port_attr_set(dev, &prev);

Netlink requests could contain multiple attributes within a single request.
Reverting to the previous value applies only to the first
swdev_port_attr_set error. It does not rollback all prior changes that
were triggered by the same Netlink request.

>+
>+	return err;
> }
> EXPORT_SYMBOL_GPL(swdev_port_attr_set);
>
>--
>1.7.10.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
