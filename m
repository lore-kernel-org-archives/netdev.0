From: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Subject: Re: MACVLANs really best solution? How about a bridge with multiple
 bridge virtual interfaces? (was Re: [PATCH] macvlan: Support creating
 macvlans from macvlans)
Date: Sun, 8 Mar 2009 09:02:12 +1030
Message-ID: <20090308090212.651e598b.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
	<49B2A139.8040507@candelatech.com>
	<m11vt9fbgj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.mail.adnap.net.au ([203.6.132.75]:53505 "EHLO
	smtp1.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161AbZCGWcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 17:32:31 -0500
In-Reply-To: <m11vt9fbgj.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 07 Mar 2009 10:13:16 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Ben Greear <greearb@candelatech.com> writes:
> 
> > Mark Smith wrote:
> >> Hi,
> >>
> >> Ben said,
> >>   
> >>> I wouldn't deny sending with wrong source mac..ethernet interfaces can do
> >>> this,
> >>> and mac-vlan should look as much like ethernet is possible.
> >>>     
> >>
> >> I agree, however there's further things that mac-vlans aren't
> >> currently doing as virtual ethernet interfaces that real ones do.
> >> Unicast ethernet traffic sent out one mac-vlan interface with a
> >> destination address of another mac-vlan interface on the same host
> >> isn't delivered. mac-vlan interfaces, even though they're conceptually
> >> located on the same ethernet segment, are currently isolated from each
> >> other for unicast traffic.
> >>   
> > At least for my use, having them all blindly TX is fine.  For thousands
> > of interfaces, if you did this right and also delivered all broadcast packets
> > locally
> > (ie, ARP), you will cause a lot of overhead, and unless you are running a
> > patched
> > kernel (or namespaces perhaps), you can't really communicate with yourself over
> > the
> > network anyway using IP.
> >
> > For the behaviour you want, try adding pairs of VETH interfaces and add one end
> > of the veth's to the bridge.  Add a physical port to the bridge for egress.
> > Since this
> > can be done, I don't really see any reason to change mac-vlan significantly...
> >
> > If the veth/bridge thing doesn't work, then let us know, as I think that would
> > be
> > a bug.  I use a similar-to-veth virtual-device pair in this way and it works
> > fine.
> 
> There is one scenario in which macvlans totally beat bridging veth
> devices.  macvlans support the full set of stateless hardware
> offloads that the hardware supports.  Whereas veth device support none
> of them.
> 
> I don't think changing macvlans makes a lot of sense.  Beyond the
> pain of making it work, there are the semantic differences of local
> broadcast working.
> 
> Doing something so that bridges have roughly the same performance 
> as macvlans would be very nice.  I think it requires advertising
> most if not all stateless hardware offloads, and then implementing
> them in software on the endpoints that don't support them.
> 
> I did get as far as implementing a first draft at looping packets back
> locally and behaviour difference for broadcasts and multicast
> differences made macvlans a bad fit.  For clean code something like
> the bridge code where you don't use the original interface directly
> for sending and receiving traffic seems required.
> 

So then, my question is, what are mac-vlans for i.e. what is their
common use case?

The problem I was trying to solve was to run up an arbitrary
number of PPPoE servers on a single LAN segment. I could do that
with physical interfaces, however I only had a maximum of 4 ethernet
interfaces in the host. Using mac-vlans seemed to be the obvious way to
eliminate the physical constraints of the host. I did expect though that
the mac-vlan virtual interfaces would work the same real interfaces, so
I was expecting that I could bridge them and that unicast traffic
between them would work.

If bridged veth pairs is a solution to my problem, what would I use
mac-vlans for? Ben seems to have a use case, however I know that he
does network testing, so some of his use cases could be quite uncommon.
I do some odd things with networking occasionally, so the mac-vlan
behaviour / limitations might be useful, but I'm curious if there would
be some more common uses?

Regards,
mark.
