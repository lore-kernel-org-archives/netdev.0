From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of switch chip datapath
Date: Wed, 26 Mar 2014 20:24:58 +0100
Message-ID: <20140326192458.GI22086@order.stressinduktion.org>
References: <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <5331ED86.7020704@mojatatu.com> <20140326111031.GB31370@hmsreliant.think-freely.org> <20140326112903.GG15723@casper.infradead.org> <20140326182122.GC31370@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Graf <tgraf@suug.ch>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33393 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727AbaCZTZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:25:00 -0400
Content-Disposition: inline
In-Reply-To: <20140326182122.GC31370@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 02:21:22PM -0400, Neil Horman wrote:
> Yes, this is the point of contention, you're right.  And you're also correct in
> that we do have several devices that bypass the network stack on the.  My
> concern is that, in all of those cases its being bypassed because we know that
> other software is handling that functionality (in the case of macvtap we know
> that we're passing it off to a guest to be processed via the full network stack
> available in the guest, and in the case of OVS, we know that we are passing
> traffic to a software defined switch for handling).  In the case of having a
> switch fabric available, we're explicitly hiding the fact that traffic we are
> passing between ports never touches the cpu, and that just rubs me the wrong
> way.  I suppose I'm looking at switch fabrics in the same way that I look at
> TOE.  In offloading forwaring functionality we remove from the cpu activity
> which an administrator may reasonably expect to see handled in the cpu, but they
> wont.  In the case of macvlan, the admin knows thats a macvlan device, and
> packet handling for frames bound to it occurs in the guest.  for OVS, packets
> recieved on the cpu with the proper encapsulation are clearly handled in the
> OVS bridge.  But in the case of a hardware switch, all they see are 4 net device
> interfaces that seem like any other net device.  
> 
> Perhaps I need to let go of this notion, but it seems to me, if we're going to
> allow cpu stack bypass, then we need to make that very obvious to an
> administrator.  Maybe a flag like IFF_L2ONLY (or perhaps better still
> IFF_LOCALDATAONLY, to indicate that only data directly addressed to the
> interface, or to a multi/broadcast address will be received by it, despite the
> promisc or other settings is sufficient). I really don't know.  Thats where my
> hang up is though.

The switch master port would actually be a normal interface only. The
ports which just get managed by the switch and don't directly communicate
with the host could have a IFF_CONFIGONLY flag to show they only react
to netlink config messages but don't handle any traffic.

Maybe we need this for routing offloading soon, too and should not try to
design for switches only but for all kind of devices which have their forwarind
plane unreachable from the kernel.

Some of the small routers integrate hardware nat by now, seems like broadcom has some
cut-through-offloading for IP already implemented on their small-routing SoCs.

So maybe we have to redo this for L3 traffic soon, too. Depends on whether we
want to support that (see TOE problematic).

Greetings,

  Hannes
