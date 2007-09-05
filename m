From: Ben Woodard <woodard@redhat.com>
Subject: WiFi and changed MAC addrs
Date: Wed, 05 Sep 2007 08:20:44 -0700
Message-ID: <46DEC94C.9010301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40309 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757119AbXIEPVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 11:21:39 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l85FLbur009369
	for <netdev@vger.kernel.org>; Wed, 5 Sep 2007 11:21:37 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l85FLbxk013361
	for <netdev@vger.kernel.org>; Wed, 5 Sep 2007 11:21:37 -0400
Received: from [10.11.15.17] (vpn-15-17.rdu.redhat.com [10.11.15.17])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l85FLYP9014890
	for <netdev@vger.kernel.org>; Wed, 5 Sep 2007 11:21:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I just spent basically a day of my weekend grappling with this problem 
http://wiki.xensource.com/xenwiki/XenWifi
before I understood it well enough to realize that the fact that Xen 
changed the MAC addr for my WiFi card was the root cause of the problem. 
This got me thinking:

If a particular piece of hardware will refuse to send frames after the 
MAC address has been changed, then shouldn't the card's driver refuse to 
allow a change of the MAC address and return an error in response to the 
IOCTL that tries to change it? I can't think of a situation where this 
wouldn't be the right thing to do. However, before I submit a patch to 
fix this, does anyone else know of any special cases that I might need 
to deal with?

Also is behavior of refusing to send frames with a non-hardware 
specified MAC address part of the WiFi spec or is it particular to 
certain WiFi cards? IOW at what level do I need to fix it? Should I just 
fix it for the Intel cards that I've tested or do I need to fix it for 
all WiFi cards?

-ben
