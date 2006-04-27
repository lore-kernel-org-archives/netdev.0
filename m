From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 27 Apr 2006 00:52:36 -0700 (PDT)
Message-ID: <20060427.005236.33630374.davem@davemloft.net>
References: <200604270817.36041.ak@suse.de>
	<20060426.232724.07687472.davem@davemloft.net>
	<200604270841.52349.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, jeff@garzik.org, kelly@au1.ibm.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35244
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932428AbWD0HxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 03:53:12 -0400
To: ak@suse.de
In-Reply-To: <200604270841.52349.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Thu, 27 Apr 2006 08:41:51 +0200

> Yes but all clients will see all the data from all sockets don't
> they?  [Unless you have a RDMA nic that can scale to hundred
> thousands of connections, but let's assume standard hardware for
> now]

Each netchannel, which goes to a specific socket, has a ring
buffer of packets the NIC can use.  Those packets are mmap()'d
into userspace so we can control the layout, the page boundaries,
etc. and the NIC will only DMA packets matching that channel ID
into that userland area.

Have a look at the code Kelly posted.
