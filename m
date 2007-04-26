From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 26 Apr 2007 09:27:59 -0400
Message-ID: <1177594079.4077.37.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902B96813@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:61609 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754779AbXDZN2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 09:28:05 -0400
Received: by wx-out-0506.google.com with SMTP id h31so578349wxd
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 06:28:04 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902B96813@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-25-04 at 10:45 -0700, Waskiewicz Jr, Peter P wrote:
> > -----Original Message-----

> The previous version of my multiqueue patches I sent for consideration
> had feedback from Patrick McHardy asking that the user be able to
> configure the PRIO qdisc to run with multiqueue support or not.  That is
> why TC needed a modification, since I agreed with Patrick that this
> would be a useful option.

Patrick is a smart guy and I am almost sure he gave you that advice
based on how your kernel patches work. Since i havent looked at your
patches, I cant swear to that as a fact - hence the "almost"

> All the versions of multiqueue network device support I've sent for
> consideration had PRIO modified to support multiqueue devices, since it
> lends itself well for the model of multiple, independent flows.
> 

So it seems your approach is to make changes to every qdisc so you can
support device-multiq, no? This is what i suspected and was questioning
earlier, not the fact you had it in tc (which is a consequence).

My view is:
- the burden of the changes should be on the driver. A thin layer
between the qdisc and driver hw tx should help hide those changes from
the qdiscs; i.e i dont see why the kernel side qdisc needs to change.
The rest you leave to the user; if the user configures HTB for a
hardware that does multiq which is WRR, then that is their problem.
The driver should be configurable to be X num of queues via probably
ethtool. It should default to single ring to maintain old behavior.

> > BTW, is there any reason this is being cced to lkml?
> 
> Since this change affects how tc interacts with the qdisc layer, I cced
> lkml.

Ok, i see; none of those other intel people put you through the hazing
yet? ;-> This is a netdev matter - so i have taken off lkml

I will try to talk to the other gent to see if we can join into this
effort instead of a parallel one; the wireless cards have similar needs.
I plan to spend time looking at your approach (sorry, my brain likes to
work that way; otherwise i would have looked at it by now).

cheers,
jamal 


