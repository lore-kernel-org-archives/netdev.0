From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [patch net-next v2] nlmon: use standard rtnetlink link api for add/del devices
Date: Tue, 16 Jul 2013 18:59:36 +0300
Message-ID: <1561418.Jq9drZzso6@lx-vladimir>
References: <1372755331-1267-1-git-send-email-jiri@resnulli.us> <loom.20130716T160603-964@post.gmane.org> <51E55D91.5050000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: <netdev@vger.kernel.org>, Jiri Pirko <jpirko@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:33150 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932441Ab3GPP7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 11:59:39 -0400
In-Reply-To: <51E55D91.5050000@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, July 16, 2013 04:49:53 PM Daniel Borkmann wrote:
> On 07/16/2013 04:08 PM, Vladimir Kondratiev wrote:
> > Jiri Pirko <jiri <at> resnulli.us> writes:
> >
> >> It is not nice when netdev is created right after module load and with
> >> some implicit name. So rather change nlmon to use standard rtnl link API.
> >
> > Could you please elaborate a bit - how to capture netlink skb's after your
> > patch? Before, it was netdev that may be used with tcpdump. Now, there is
> > no such netdev. How to create it?
> 
> modprobe nlmon
> ip link add type nlmon
> ip link set nlmon0 up
> 
> tcpdump -i nlmon0 ....
> 
> ip link set nlmon0 down
> ip link del dev nlmon0
> rmmod nlmon

Thanks a lot! I guess it is worth to have this mentioned somewhere.
It will save lots of questions. For example, in Kconfig:

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b45b240..13acea2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -247,8 +247,18 @@ config NLMON
          purpose of this is to analyze netlink messages with packet sockets.
          Thus applications like tcpdump will be able to see local netlink
          messages if they tap into the netlink device, record pcaps for further
-         diagnostics, etc. This is mostly intended for developers or support
-         to debug netlink issues. If unsure, say N.
+         diagnostics, etc. Typical flow is:
+
+           modprobe nlmon
+           ip link add type nlmon
+           ip link set nlmon0 up
+           tcpdump -i nlmon0 ....
+           ip link set nlmon0 down
+           ip link del dev nlmon0
+           rmmod nlmon
+
+         This is mostly intended for developers or support to debug netlink
+         issues. If unsure, say N.
 
 endif # NET_CORE
