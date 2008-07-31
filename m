From: "Karen Xie" <kxie@chelsio.com>
Subject: RE: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 30 Jul 2008 18:24:05 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334032EC7F5@maui.asicdesigners.com>
References: <200807300019.m6U0JkdY012558@localhost.localdomain> <4890C287.60508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <open-iscsi@googlegroups.com>,
	<davem@davemloft.net>, <michaelc@cs.wisc.edu>,
	"Steve Wise" <swise@opengridcomputing.com>, <rdreier@cisco.com>,
	<daisyc@us.ibm.com>, <wenxiong@us.ibm.com>, <bhua@us.ibm.com>,
	"Divy Le Ray" <divy@chelsio.com>,
	"Dimitrios Michailidis" <dm@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>,
	"linux-scsi" <linux-scsi@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Comments:
>
>* SCSI drivers should be submitted via the linux-scsi@vger.kernel.org 
>mailing list.

Will do that. Thanks.

>
>* The driver is clean and readable, well done
>
>* From a networking standpoint, our main concern becomes how this 
>interacts with the networking stack.  In particular, I'm concerned
based 
>on reading the source that this driver uses "TCP port stealing" rather 
>than using a totally separate MAC address (and IP).
>
>Stealing a TCP port on an IP/interface already assigned is a common 
>solution in this space, but also a flawed one.  Precisely because the 
>kernel and applications are unaware of this "special, magic TCP port" 
>you open the potential for application problems that are very difficult

>for an admin to diagnose based on observed behavior.

The collisions between the host stack and iSCSI offload are unlikely
because the iSCSI target server's port is unique (nailed down as 3260).
If an offload card is plugged in, all iSCSI connections to a given
target (i.e., destination/port) are offloaded. There is precedence for
this approach such as RDMA/iWarp.

>
>So, additional information on your TCP port usage would be greatly 
>appreciated.  Also, how does this interact with IPv6?  Clearly it 
>interacts with IPv4...

Currently, IPv6 connection request will not be honored, I will make sure
the checking is added in the resubmission.

