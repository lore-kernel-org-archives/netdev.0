From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: update some distro-specific documentation
Date: Wed, 12 Sep 2007 11:47:36 -0700
Message-ID: <1085.1189622856@death>
References: <20070830212429.GA12676@gospo.rdu.redhat.com> <21001.1189189669@death> <20070912181839.GD3754@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:56969 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933509AbXILSrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 14:47:40 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8CIlcmZ032511
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 14:47:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CIlcUi451948
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 12:47:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CIlbLe010900
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 12:47:38 -0600
In-reply-to: <20070912181839.GD3754@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>I could do that, or we could just take this as-is and get initscripts
>fixed up to account for this.  Does that seem reasonable?

	Changing initscripts is fine, too, but is there then going to be
some (perhaps small) installed base for which the documentation will be
incorrect?

>I'd rather go that route, and I've even got a patch that *seems* to work
>already:
>
>--- initscripts-8.45.17.EL/sysconfig/network-scripts/ifup-eth.orig
>+++ initscripts-8.45.17.EL/sysconfig/network-scripts/ifup-eth
>@@ -125,7 +125,16 @@ if [ "$ISALIAS" = no ] && is_bonding_dev
>     for arg in $BONDING_OPTS ; do   
>         key=${arg%%=*};
>         value=${arg##*=};
>-        echo $value > /sys/class/net/${DEVICE}/bonding/$key
>+        OLDIFS=$IFS;
>+        IFS=',';
>+        if [ "${key}" = "arp_ip_target" ]; then
>+           for arp_ip in $value; do
>+             echo +$arp_ip > /sys/class/net/${DEVICE}/bonding/$key
>+           done
>+        else
>+           echo $value > /sys/class/net/${DEVICE}/bonding/$key
>+        fi
>+        IFS=$OLDIFS;
>     done
>
>     /sbin/ip link set dev ${DEVICE} up

	That looks like it should do the right thing, although I didn't
actually try it.  The other bonding sysfs thingies that use the "+" type
of syntax don't appear in BONDING_OPTS.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


