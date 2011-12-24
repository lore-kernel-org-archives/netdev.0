From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: route classifiers and mirred actions
Date: Sat, 24 Dec 2011 12:47:20 -0500
Message-ID: <1324748840.3200.20.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:55230 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753028Ab1LXRr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 12:47:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I may have a workaround for the problem we have using netem
with ingress filters but I have hit a roadblock in implementing it.  It
appears I cannot use an action with a route classifier.  Specifically:

root@testswitch01:~# tc filter add dev eth0 parent ffff: protocol ip prio 50 route fromif eth1 action mirred egress redirect dev ifb1
What is "action"?
Usage: ... route [ from REALM | fromif TAG ] [ to REALM ]
                [ flowid CLASSID ] [ police POLICE_SPEC ]
       POLICE_SPEC := ... look at TBF
       CLASSID := X:Y

NOTE: CLASSID is parsed as hexadecimal input.
root@testswitch01:~# tc action add action mirred help
Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME>
where:
        DIRECTION := <ingress | egress>
        ACTION := <mirror | redirect>
        INDEX  is the specific policy instance id
        DEVICENAME is the devicename

Yet, this works:

root@testswitch01:~# tc filter add dev eth0 parent ffff: protocol ip prio 50 u32 match u32 0 0 action mirred egress redirect dev ifb1

and this works:

root@testswitch01:~# tc filter add dev eth0 parent ffff: protocol ip prio 1 route fromif eth1 classid 1:10


So why does the u32 classifier work with actions, the route classifier
work with classids, but the route classifier does not work with actions?
Thanks - John
