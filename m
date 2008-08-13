From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 16:12:37 -0700 (PDT)
Message-ID: <20080813.161237.10205799.davem@davemloft.net>
References: <ada3al8k3l5.fsf@cisco.com>
	<20080813.150831.193391799.davem@davemloft.net>
	<adatzdoiklo.fsf@cisco.com>
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
In-Reply-To: <adatzdoiklo.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 13 Aug 2008 16:03:15 -0700

> OK, I admit you could make something work -- add hooks for the low-level
> driver to ask the iSCSI initiator where PDU boundaries are so it can
> resync when something is evicted from the flow cache, have the initiator
> format its tags in a special way to encode placement data, etc, etc.
> The scheme does bring to mind Alan's earlier comment about pigs and
> propulsion, though.

There would need to be _NO_ hooks into the iSCSI initiator at all.

The card would land the block I/O data onto the necessary page boundaries
and the iSCSI code would just be able to thus use the pages directly
and as-is.

It would look perfectly like normal TCP receive traffic.  No hooks,
no special cases, nothing like that.

> In any case, as I said in the part of my email that you snipped, the
> real issue is not designing hypothetical hardware, but deciding how to
> support the Chelsio, Broadcom, etc hardware that exists today.

The same like we support TOE hardware that exists today.  That is, we
don't.


