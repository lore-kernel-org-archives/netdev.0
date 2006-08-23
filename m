From: =?iso-8859-1?Q?Michal_Ruzicka?= <michal.ruzicka@comstar.cz>
Subject: multicast group memberships purge on interface delete
Date: Wed, 23 Aug 2006 13:08:11 +0200
Message-ID: <021e01c6c6a4$6e7845f0$2303a8c0@mruzicka>
References: <20060809.195627.59155708.yoshfuji@linux-ipv6.org>	<44D9D431.10101@tcs.hut.fi>	<44DA558A.1080706@tcs.hut.fi> <20060810.174635.42119608.yoshfuji@linux-ipv6.org> <44DB0870.6000902@tcs.hut.fi> <019901c6bc75$872ee1f0$2303a8c0@mruzicka>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:30386 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S964882AbWHWLIQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 07:08:16 -0400
Received: from mruzicka (mruzicka.plz.comstar.cz [192.168.3.35])
	by gateplz.comstar.cz (8.12.8/8.12.8) with SMTP id k7NB8F6u022453
	for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 13:08:15 +0200
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello there,
I've got the following question/suggestion:

The situation today:
When an interface is deleted and there happen to have been some multicast 
groups joined on it only
the interface's list of multicast meberships is deleted. The sockets through 
which the groups
were joined and more importantly their associated multicast membership lists 
are left untouched.
This makes it difficult for the function that handles leaving multicast 
groups on a socket to decide
what to do with groups that were joined on such an interface (that no longer 
exists). The present
implementation is a kind of  a "best guess" (and nothnig better can probably 
be done about that).
It may even fail to leave an affected group (group that was joined on a 
deleted interface) completely
and thus block a slot in the sockets's multicast mebership list which size 
is purposely limited.

My question/suggestion:
Would it feasible to drop the relevant entries from sockets' multicast 
membership lists on the interface
delete? Yes, I do realize it would require to walk through a number of 
sockets to see if there is any
multicast entry for the interface in question to delete. But this could be 
optimized by maintaining a list
of sockets that have a multicast group joined on the interface (and keep a 
pointer to this list in the
device structure). This would ease the job of the function handling leaving 
multicast groups, made
its beahaviour more "deterministic" and possible errors reported by it more 
meaningful/reliable.

Notes:
- The suggested approach is reportedly taken by other OSes (notably NetBSD). 
The fact
that linux doesn't behave the same poses a problem for cross platform 
software for the behaviour
of different systems is different in one more detail.
- The suggested "list of sockets that have a multicast group joined on the 
interface" could also
probably be of some help when maintaining the per interface multicast source 
filter list or
per-interface multicast reception state as per RFC 3376 (IGMPv3) section 
3.2.

Thanks
Michal Ruzicka 

