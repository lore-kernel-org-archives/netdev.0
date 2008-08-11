From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 09:07:51 -0700
Message-ID: <adafxpbzga0.fsf@cisco.com>
References: <489C8BEB.8060001@opengridcomputing.com>
	<489CC58D.4010606@pobox.com> <adazlnlzc60.fsf@cisco.com>
	<20080809.224637.69833549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, swise@opengridcomputing.com, divy@chelsio.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080809.224637.69833549.davem@davemloft.net> (David Miller's
	message of "Sat, 09 Aug 2008 22:46:37 -0700 (PDT)")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Why show these special connections if the user cannot interact with or
 > shape the stream at all like normal ones?

So that an admin can see what connections are open, so that the stack
doesn't try to reuse the same 4-tuple for another connection, etc, etc.

 > And I even wonder, these days, if you probably get %90 or more of the
 > gain these "optimized" iSCSI connections obtain from things like LRO.

Yes, that's the question -- are stateless offloads (plus CRC32C in the
CPU etc) going to give good enough performance that the whole TCP
offload exercise is pointless?  The only issue is that I don't see how
to avoid the fundamental 3X increase in memory bandwidth that is chewed
up if the NIC can't do direct placement.

 - R.
