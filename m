From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 25/26] switchdev: convert
 swdev_fib_ipv4_add/del over to swdev_port_obj_add/del
Date: Wed, 1 Apr 2015 13:47:02 +0200
Message-ID: <20150401114702.GC2025@nanopsycho.orion>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
 <1427882882-2533-26-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:35261 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152AbbDALrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 07:47:06 -0400
Received: by wgdm6 with SMTP id m6so50283907wgd.2
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 04:47:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427882882-2533-26-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 01, 2015 at 12:08:01PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>

...

>@@ -63,10 +73,6 @@ struct swdev_obj {
>  * @swdev_port_obj_add: Add an object to port (see swdev_obj).
>  *
>  * @swdev_port_obj_del: Delete an object from port (see swdev_obj).
>- *
>- * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
>- *
>- * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
>  */
> struct swdev_ops {
> 	int	(*swdev_port_attr_get)(struct net_device *dev,
>@@ -77,13 +83,6 @@ struct swdev_ops {
> 				      struct swdev_obj *obj);
> 	int	(*swdev_port_obj_del)(struct net_device *dev,
> 				      struct swdev_obj *obj);
>-	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
>-				      int dst_len, struct fib_info *fi,
>-				      u8 tos, u8 type, u32 nlflags,
>-				      u32 tb_id);
>-	int	(*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
>-				      int dst_len, struct fib_info *fi,
>-				      u8 tos, u8 type, u32 tb_id);

Can you please elaborate more why generic add/del functions are better
than specific ones? Me personally I don't like this kind of approach. It
makes sense for atts, where we will probably end up in bigger number of
attrs and having setter/getter for each would not be optimal.

But for objs, what other objs do you expect? Why don't have a set of SDOs
for each. Speaking of SDOs, I thought that having many of them was the
reason you ripped them out of NDO struct. Now it looks like there will
be 4 SDOs forever. Maybe I'm missing something...
