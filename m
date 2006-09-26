From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC][PATCH 1/3] enable bonding to enslave non ARPHRD_ETHER netdevices
Date: Tue, 26 Sep 2006 12:23:21 -0700
Message-ID: <200609261923.k8QJNLZt021182@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261316420.24189@zuben>
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:44451 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S932485AbWIZTX2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 15:23:28 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8QJNNhG004749
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 15:23:23 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8QJNNCK274598
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 13:23:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8QJNMWO016248
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 13:23:23 -0600
To: Or Gerlitz <ogerlitz@voltaire.com>
In-reply-to: <Pine.LNX.4.64.0609261316420.24189@zuben> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <ogerlitz@voltaire.com> wrote:
[...]
+	bond->dev->mtu		    = new_active->dev->mtu;

	This won't generate a NETDEV_CHANGEMTU notifier event.

[...]
>+		/* bonding netdevices are created with ether_setup, so when the
>+		 * slave type is not ARPHRD_ETHER there is a need to override
>+		 * some of the type dependent attributes/functions
>+		 */
>+		if (new_active && new_active->dev->type != ARPHRD_ETHER)
>+			bond_setup_by_slave(bond, new_active);
>+

	In this case, if the bond has one slave that's ARPHRD_ETHER and
one that's not, when the active changes from the non-ARPHRD_ETHER slave
to the ARPHRD_ETHER slave, it won't call bond_setup_by_slave() to switch
the hard_header, rebuild_header, et al, back to the ARPHRD_ETHER
settings.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
