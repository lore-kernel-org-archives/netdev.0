From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Fri, 12 Jun 2015 11:46:59 +0200
Message-ID: <20150612094659.GB5289@pox.localdomain>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
 <20150609101550.GA10411@pox.localdomain>
 <CAJmoNQHRTJwdMjziQiPBX07sZKrYd3Z1ASNi1xQZdgJ1Vs6bGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Ahern <dsahern@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jon Toppins <jtoppins@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:33645 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbbFLJrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 05:47:02 -0400
Received: by wgez8 with SMTP id z8so20806043wge.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 02:47:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJmoNQHRTJwdMjziQiPBX07sZKrYd3Z1ASNi1xQZdgJ1Vs6bGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/15 at 01:43pm, Shrijeet Mukherjee wrote:
> On Tue, Jun 9, 2015 at 3:15 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > Do I understand this correctly that swp* represent veth pairs?
> > Why do you have distinct addresses on each peer of the pair?
> > Are the addresses in N2 and N3 considered private and NATed?
> >
> > [...]
> >
> >
> ???These are physical boxes in the picture not veth pairs or NAT's :)???

I see. So if I translate this to a virtual world with veths where
the guest facing peer is in its own netns, the host facing veth
peer would get attached to a vrf device and we should be good.

> ???Are you worried about ip rule scale ? this reduces the scale to number of
> L3 domains, which should be not that large. I do think we need to speed up
> rule lookup from the linear walk we have right now.

I definitely have more L3 domains than what a linear search can
handle.

> A generic classifier seems like a bigger hammer, but if that is the way to
> replace rules it is a worthy concept.
> 
> That said, the patches from Hannes et al, will make it such that the table
> lookup maybe from the driver directly and thus will skip past the fib rule
> lookup.

The approach from Hannes definitely works for the physical world
but is undesirable for overlays, logical or encapsulations, where
we want to avoid maintaining a net_device for every virtual network.

As I said, I think this is something that can be resolved later on
with a programmable classifier.
