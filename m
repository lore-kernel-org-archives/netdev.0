From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Mon, 14 Oct 2013 17:32:05 -0400
Message-ID: <525C62D5.3090004@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:41565 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754984Ab3JNVcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 17:32:09 -0400
Received: by mail-qe0-f43.google.com with SMTP id nc12so5701779qeb.30
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 14:32:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IOW, TheCutNpasteTrain.

There's a lot of clutter on the netlink interface used
by bridge and vxlan.
1) A lot of things which are boolean on/off end up using a uchar.
Example:
IFLA_BRPORT_MODE, IFLA_BRPORT_GUARD, IFLA_BRPORT_PROTECT,
IFLA_BRPORT_LEARNING, IFLA_BRPORT_UNICAST_FLOOD, BRIDGE_VLAN_INFO_PVID,
BRIDGE_VLAN_INFO_UNTAGGED, BRIDGE_MODE_VEPA,
IFLA_VXLAN_PROXY,IFLA_VXLAN_RSC, etc

2) There's a few fields which are basically intended to project the
same message to the kernel but are redefined a few times:
Example:
BRIDGE_VLAN_INFO_MASTER vs NTF_MASTER vs BRIDGE_FLAGS_MASTER

Also i am not sure why multicast snooping needs its own subheader.

Is it too late to make changes? git logs shows some of these feature
have only been on the last 2-3 months.
One approach to resolve this is introduce a new BRIDGE_FLAGS TLV
which will work like the ifi_flags/change and put all these flags in
one spot. New iproute will use these and the old one will continue using
the old approach. It would require to EOL the old interface at some
point.

If this is agreeable and it is not on someone todo list - I will send
patches later on.

cheers,
jamal
