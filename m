From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: more findings/questions on vlans/bonds
Date: Tue, 07 Apr 2009 07:13:59 -0700
Message-ID: <5325.1239113639@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com>
Cc: netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:60079 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbZDGOOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 10:14:21 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n37EBAn3020727
	for <netdev@vger.kernel.org>; Tue, 7 Apr 2009 08:11:10 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n37EE6eo086372
	for <netdev@vger.kernel.org>; Tue, 7 Apr 2009 08:14:06 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n37EDu3x009426
	for <netdev@vger.kernel.org>; Tue, 7 Apr 2009 08:13:56 -0600
In-reply-to: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@voltaire.com> wrote:
[...]
>I hope that you can help clarify what's the correct/supported method
>to work with vlans and bonds, with 2.6.29 I see that one can either
>
>[I pasted in the fixed text here]
> 	- vlan a bond (bond0.4001 over bond0 over eth0/1)
> 	- bond vlans (e.g bond0 over eth0/1.4001 over eth0/1)

	I'll have to look into this, but my recollection is that you
should be able to do either of the above.  I haven't tested the second
flavor lately, but I believe it should work.  It's arguably only better
than the first alternative if, for some reason, the user wants to either
load balance or fail over across multiple VLANs, but (if all slaves are
on the same VLAN) the two above scenarios should be functionally
equivalent.

>I played a bit with bonding vlans (2.6.29 active-backup mode) and it
>doesn't seem to work - specifically, I noted that bonding doesn't issue
>fail-over after I changed the current slave link status to down ("ifconfig
>eth0.4001 down"). I suspect that the carrier based link monitoring scheme
>is broken wrt to vlan devices - e.g I found that at least from sysfs
>perspective the vlan device carrier isn't available:
>
>$ cat /sys/class/net/eth0.4001/carrier
>cat: /sys/class/net/eth0.4001/carrier: Invalid argument
>
>I also played with a post 2.6.29 cut of Linus tree, and I couldn't bond vlans.
>I thought that the reason may be that a vlan device has already master -
>but I found out that its wrong and vlans don't have the IFF_SLAVE bit set
>in their flags bit mask. So this may be either something wrong on my side
>or a bug introduced after 2.6.29 or just something which isn't supported,
>e.g following my findings with 2.6.29 above...

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
