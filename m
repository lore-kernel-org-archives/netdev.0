From: Pekka Savola <pekkas@netcore.fi>
Subject: /proc/net/igmp group address encoding
Date: Wed, 24 Sep 2008 13:31:32 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0809241326070.30892@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:46560 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbYIXKbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 06:31:36 -0400
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id m8OAVXt7031024
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 13:31:33 +0300
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id m8OAVWmA031021
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 13:31:33 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've spotted some irritating IGMPv3/v2 compat problems on RHEL4, and 
I'm working on trying to see if these are due to bugs already fixed in 
latest kernels.  In the process, I started wondering about 
/proc/net/igmp format (on 2.6.26.5-39.fc9.i686):

[psavola@lapps ~]$ more /proc/net/igmp
Idx	Device    : Count Querier	Group    Users Timer	Reporter
1	lo        :     0      V3
 				010000E0     1 0:00000000		0
2	eth0      :     2      V3
 				010000E0     1 0:00000000		0
3	wmaster0  :     3      V3
 				010000E0     1 0:00000000		0
4	wlan0     :     3      V3
 				010000E0     1 0:00000000		0

(The header and the fields seem to be a little off in the output..)

[psavola@lapps ~]$ netstat -gn | grep eth0
eth0            1      224.0.0.1
eth0            1      ff02::1

It appears "010000E0" is 224.0.0.1 encoded in in hex but 
right-to-left.  Other groups are similarly encoded.  /proc/net/igmp6 
is encoded in a human-friendly format.

Is this intentional?  Should this be changed, e.g. to flow 
left-to-right and use the dotted quad IP address format?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
