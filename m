From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next 0/3] net: switchdev: extract specific object
 structures
Date: Wed, 9 Sep 2015 08:45:15 +0200
Message-ID: <20150909064515.GA2119@nanopsycho.orion>
References: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35352 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbIIGpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 02:45:18 -0400
Received: by wicge5 with SMTP id ge5so141964263wic.0
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 23:45:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 08, 2015 at 10:47:52PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Hi!
>
>Current implementations of .switchdev_port_obj_add and .switchdev_port_obj_dump
>must pass the generic switchdev_obj structure instead of a specific one (e.g.
>switchdev_obj_fdb) to the related driver accessors, because it contains the
>object transaction and callback. This is not very convenient for drivers.
>
>Instead of having all specific structures included into a switchdev_obj union,
>it would be simpler to embed a switchdev_obj structure as the first member of
>the more specific ones. That way, a driver can cast the switchdev_obj pointer
>to the specific structure and have access to all the information from it.
>
>As an example, this allows Rocker to change its two FDB accessors:
>
>    rocker_port_fdb_add(rocker_port, obj->trans, &obj->u.fdb);
>    rocker_port_fdb_dump(rocker_port, obj);
>
>for these most consistent ones:
>
>    fdb = (struct switchdev_obj_fdb *) obj;
>    rocker_port_fdb_add(rocker_port, fdb);
>    rocker_port_fdb_dump(rocker_port, fdb);
>
>This is what struct netdev_notifier_info and its specific supersets (e.g.
>struct netdev_notifier_changeupper_info) do in include/linux/netdevice.h.
>
>This patchset does that and updates bridge, Rocker and DSA accordingly.
>
>Note that this patchset was sent as an RFC not to bother David with new
>net-next stuffs, but if the changes look good, it is ready to merge.
>
>Also, please take note that the change sits on top of:
>http://patchwork.ozlabs.org/patch/514894/
>
>Vivien Didelot (3):
>  net: switchdev: extract switchdev_obj_vlan
>  net: switchdev: extract switchdev_obj_ipv4_fib
>  net: switchdev: extract switchdev_obj_fdb

I like this patchset a lot! I think it is the right way. Thanks for doing this.
