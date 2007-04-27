From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 27 Apr 2007 11:09:58 -0400
Message-ID: <1177686598.4059.79.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902B9710F@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:21910 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973AbXD0PKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 11:10:06 -0400
Received: by wx-out-0506.google.com with SMTP id h31so931803wxd
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 08:10:05 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902B9710F@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-26-04 at 09:30 -0700, Waskiewicz Jr, Peter P wrote:
> > jamal wrote:
> > > On Wed, 2007-25-04 at 10:45 -0700, Waskiewicz Jr, Peter P wrote:

> We have plans to write a new qdisc that has no priority given to any
> skb's being sent to the driver.  The reasoning for providing a
> multiqueue mode for PRIO is it's a well-known qdisc, so the hope was
> people could quickly associate with what's going on.  The other
> reasoning is we wanted to provide a way to prioritize various network
> flows (ala PRIO), and since hardware doesn't currently exist that
> provides flow prioritization, we decided to allow it to continue
> happening in software.
> 

Reading the above validates my fears that we have some strong
differences (refer to my email to Patrick). To be fair to you, i would
have to look at your patches. Now i am actually thinking not to look at
them at all incase they influence me;->
I think the thing for me to do is provide alternative patches and then
we can have smoother discussion.
The way i see it is you dont touch any qdisc code. qdiscs that are
provided by Linux cover a majority of those provided by hardware
(Heck, I have was involved on an ethernet switch chip from your company
that provided strict prion multiqueues in hardware and didnt need to
touch the qdisc code)

> > 
> > > The driver should be configurable to be X num of queues via 
> > probably 
> > > ethtool. It should default to single ring to maintain old behavior.
> > 
> > 
> > That would probably make sense in either case.
> 
> This shouldn't be something enforced by the OS, rather, an
> implementation detail for the driver you write.  If you want this to be
> something to be configured at run-time, on the fly, then the OS would
> need to support it.  However, I'd rather see people try the multiqueue
> support as-is first to make sure the simple things work as expected,
> then we can get into run-time reconfiguration issues (like queue
> draining if you shrink available queues, etc.).  This will also require
> some heavy lifting by the driver to tear down queues, etc.
> 

It could be probably a module insertion/boot time operation.

> > 
> > > Ok, i see; none of those other intel people put you through 
> > the hazing 
> > > yet? ;-> This is a netdev matter - so i have taken off lkml
> > > 
> 
> I appreciate the desire to lower clutter from mailing lists, but I see
> 'tc' as a kernel configuration utility, and as such, people should know
> what we're doing outside of netdev, IMO.  But I'm fine with keeping this
> off lkml if that's what people think.
> 

All of netdev has to do with the kernel - that doesnt justify cross
posting.
People interested in network related subsystem development will
subscribe to netdev. Interest in scsi =. subscribe to scsi mailing lists
etc.


cheers,



