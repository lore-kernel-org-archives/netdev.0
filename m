From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 15:08:31 -0700 (PDT)
Message-ID: <20080813.150831.193391799.davem@davemloft.net>
References: <adad4kfxm9v.fsf@cisco.com>
	<20080811.145313.178992274.davem@davemloft.net>
	<ada3al8k3l5.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, jgarzik@pobox.com, swise@opengridcomputing.com,
	divy@chelsio.com, kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <ada3al8k3l5.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 13 Aug 2008 14:27:50 -0700

> I don't see how this could work.  First, it seems that you have to let
> the adapter know which connections are iSCSI connections so that it
> knows when to try and parse iSCSI headers.

It always starts from offset zero for never seen before connections.

> So you're already not totally stateless.

Yes, we are.

> Then, since (AFAIK -- I'm not an expert on iSCSI and
> especially I'm not an expert on what common practice is for current
> implementations) the iSCSI PDUs can start at any offset in the TCP
> stream, I don't see how a stateless adapter can even find the PDU
> headers to parse -- there's not any way that I know of to recognize
> where a PDU boundary is without keeping track of the lengths of all the
> PDUs that go by (ie you need per-connection state).

Like I said, you retain a "flow cache" (say it a million times, "flow
cache") that remembers the current parameters and the buffers
currently assigned to that flow and what offset within those buffers.
