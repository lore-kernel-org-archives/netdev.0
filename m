From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Fri, 12 Oct 2007 10:05:00 -0700
Message-ID: <20071012100500.02255243@freepuppy.rosehill>
References: <20071010003716.GB552@one.firstfloor.org>
	<36D9DB17C6DE9E40B059440DB8D95F5203887DD1@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Andi Kleen" <andi@firstfloor.org>,
	"David Miller" <davem@davemloft.net>, <hadi@cyberus.ca>,
	<jeff@garzik.org>, <johnpol@2ka.mipt.ru>,
	<herbert@gondor.apana.org.au>, <gaagaan@gmail.com>,
	<Robert.Olsson@data.slu.se>, <netdev@vger.kernel.org>,
	<rdreier@cisco.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<mcarlson@broadcom.com>, <jagana@us.ibm.com>,
	<general@lists.openfabrics.org>, <mchan@broadcom.com>,
	<tgraf@suug.ch>, <randy.dunlap@oracle.com>, <sri@us.ibm.com>,
	<kaber@trash.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54119 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758656AbXJLRKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 13:10:21 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5203887DD1@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007 09:08:58 -0700
"Brandeburg, Jesse" <jesse.brandeburg@intel.com> wrote:

> Andi Kleen wrote:
> >> When the hw TX queue gains space, the driver self-batches packets
> >> from the sw queue to the hw queue.
> > 
> > I don't really see the advantage over the qdisc in that scheme.
> > It's certainly not simpler and probably more code and would likely
> > also not require less locks (e.g. a currently lockless driver
> > would need a new lock for its sw queue). Also it is unclear to me
> > it would be really any faster.
> 
> related to this comment, does Linux have a lockless (using atomics)
> singly linked list element?  That would be very useful in a driver hot
> path.

Use RCU? or write a generic version and get it reviewed.  You really
want someone with knowledge of all the possible barrier impacts to
review it.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
