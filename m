From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: multiqueue interrupts...
Date: Fri, 19 Sep 2008 13:57:58 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F520632FB45@orsmsx418.amr.corp.intel.com>
References: <20080918.193815.175549834.davem@davemloft.net> <41b516cb0809191050t6c9783dele8926f697854bb1@mail.gmail.com> <20080919181840.GE30956@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Arjan van de Ven" <arjan@infradead.org>,
	"Brice Goglin" <brice@myri.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
To: "Matthew Wilcox" <matthew@wil.cx>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11200 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722AbYISU6z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 16:58:55 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080919181840.GE30956@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthew Wilcox wrote:
>> So let's make an effort to get this done right in 2.6.28 and
>> meanwhile Arjan can add the irqbalanced code.
 
> Another idea I've been thinking about is a flag to tell irqbalance to
> leave stuff alone, and we just set stuff up right the first time.

There is already this flag called IRQF_NOBALANCING, at least I think
that's what we want.  irqbalanced's treatment of this flag is another
matter.
 
> We were discussing various options around multiqueue at first the scsi
> multiqueue BOF and later at the PCI MSI BOF.  There's a general
> feeling that drivers should be given some guidance about how many
> queues they should be enabling, and the sysadmin needs to be the one
> telling the PCI layer, which drivers should then query.  The use
> cases vary wildly depending whether you're doing routing or are an
> end node, whether you're doing v12n or NUMA or both and on just how
> many cards and cpus you have.

not a bad, idea, but I can appreciate why DaveM thinks this is
un-necessary.  However all we are left with right now is code changes or
module parameters when trying to configure the number of queues.

How about some new ethtool options having to do with multiqueue
configurations?  Here is a proposal.  I haven't spent much time thinking
about this before but here is an idea.

query multiqueue capabilities:
ethtool -q ethX

set multiqueue capabilities:
ethtool -Q tx N rx N int <fixedcpu|pairs|somethingelse?>

tx N and rx N are pretty self explanitory
int fixedcpu - each queue gets a cpu and is registered IRQF_NOBALANCING
int pairs - tx and rx queues are allocated per cpu and (probably) share
a vector
There should be others here, I'm not sure how/if we would want to make a
pluggable way to do this within ethtool's design without opening buffer
overlow kinds of holes.
 
> In a storage / NUMA configuration we really want to set up one queue
> per cpu / package / node (depending on resource constraints) and know
> that the interrupt is going to come back to the same cpu / package /
> node. We definitely don't want irqbalanced moving the interrupt
> around. 

ethtool doesn't help storage, but I read this on netdev anyway...

Jesse
