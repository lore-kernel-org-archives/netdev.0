From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Tue, 12 Aug 2008 15:01:40 -0700 (PDT)
Message-ID: <20080812.150140.200481459.davem@davemloft.net>
References: <adad4kfxm9v.fsf@cisco.com>
	<20080811.145313.178992274.davem@davemloft.net>
	<200808121457.11356.divy@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, rick.jones2@hp.com, jgarzik@pobox.com,
	swise@opengridcomputing.com, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, dm@chelsio.com, leedom@chelsio.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: divy@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200808121457.11356.divy@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Tue, 12 Aug 2008 14:57:09 -0700

> iSCSI PDUs might spawn over multiple TCP segments, it is unclear to me how to 
> do placement without keeping some state of the transactions.

You keep a flow table with buffer IDs and offsets.

The S2IO guys did something similar for one of their initial LRO
impelementations.

It's still strictly stateless, and best-effort.  Entries can fall out
of the flow cache which makes upcoming data use new buffers and
offsets.

But these are the kinds of tricks you hardware folks should be
more than adequately able to design, rather than me. :-)
