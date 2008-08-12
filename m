From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Tue, 12 Aug 2008 14:57:09 -0700
Message-ID: <200808121457.11356.divy@chelsio.com>
References: <48A08145.6060703@hp.com> <adad4kfxm9v.fsf@cisco.com> <20080811.145313.178992274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, rick.jones2@hp.com, jgarzik@pobox.com,
	"Steve Wise" <swise@opengridcomputing.com>,
	"Karen Xie" <kxie@chelsio.com>, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	"Dimitrios Michailidis" <dm@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080811.145313.178992274.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 11 August 2008 02:53:13 pm David Miller wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Mon, 11 Aug 2008 14:41:16 -0700
>
> >  > > Probably depends on whether or not the iSCSI offload solutions are
> >  > > doing zero-copy receive into the filecache?
> >  >
> >  > That's a data placement issue, which also can be solved with
> >  > stateless offloading.
> >
> > How can you place iSCSI data properly with only stateless offloads?
>
> By teaching the stateless offload how to parse the iSCSI headers
> on the flow and place the data into pages at the correct offsets
> such that you can place the pages hanging off of the SKB directly
> into the page cache.

Hi Dave,

iSCSI PDUs might spawn over multiple TCP segments, it is unclear to me how to 
do placement without keeping some state of the transactions.

In any case, such a stateless solution is not yet designed, whereas 
accelerated iSCSI is available now, from us and other companies.
The accelerated iSCSI streams benefit from the performance TOE provides, 
outlined in the following third party papers:
http://www.chelsio.com/assetlibrary/pdf/redhat-chelsio-toe-final_v2.pdf
http://www.chelsio.com/assetlibrary/pdf/RMDS6BNTChelsioRHEL5.pdf

iSCSI is primarily targeted to the data center, where the SW stack's traffic 
shaping features might be redundant with specialized equipment. It should 
however be possible to integrate security features on a per offoaded 
connection basis, and TOEs - at least ours :) - are capable of rate control 
and traffic shaping.

While CPU and - to a far lesser extent - memory performance improves, so does 
ethernet's. 40G, 100G are not too far ahead. It is not obvious at all that 
TOE is a point of time solution, especially for heavy load traffic as in a 
storage environment. It is quite the opposite actually.

There is room for co-existence of the SW managed traffic and accelerated 
traffic. As our submission shows, enabling accelerated iSCSI is not intrusive 
code wise to the stack. The port stealing issue is solved if we can grab a 
port from the stack.

Cheers,
Divy
