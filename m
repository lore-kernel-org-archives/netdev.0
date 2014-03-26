From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 11:22:15 -0400
Message-ID: <20140326152215.GB12372@tuxdriver.com>
References: <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com>
 <20140326111031.GB31370@hmsreliant.think-freely.org>
 <20140326112903.GG15723@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
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
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40914 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbaCZPaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 11:30:46 -0400
Content-Disposition: inline
In-Reply-To: <20140326112903.GG15723@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 11:29:03AM +0000, Thomas Graf wrote:
> On 03/26/14 at 07:10am, Neil Horman wrote:
> > But by creating net_devices that are registered in the current fashion we
> > implicitly agree to levels of functionality that are assumed to be available and
> > as such are not within the purview of a net_device to reject.  E.g. it is
> > assumed that a netdevice can filter frames using iptables/ebtables, limit
> > traffic using tc, etc.
> 
> I think this is the point where we disagree. We already have several
> devices that hook into the rx handler and never have their packets
> pass through either iptables or ebtables. Better examples of this are
> macvtap or OVS.
> 
> What should happen is that these devices are given a chance to implement
> the ACL in their own flow table. If no such facility exists, the rule
> insertion should fall back to software mode if that is possible (an
> OF capable switching chip could insert a 'upcall' flow), or as
> a last resort return an error to indicate EOPNOTSUPP.

This part makes sense to me -- use the hardware forwarding offloads if
they are available, but fall back to software for sake of flexibility.
It gives the admin enough rope to shoot himself in the foot...

> 
> > And if a switch fabric is short cutting traffic so that
> > the cpu doesn't see them, those bits of functionality won't work.  I agree we
> > can likely work around that with richer feature capabilities, but such an
> > infrastructure would both require extensive kernel changes to fully cover the
> > set of existing features at a sufficient granularity, and require user space
> > changes to grok the feature set of a given device.  Not saying its impossibible
> > or even undesireable mind you, just thats its not any less invasive than what
> > I'm proposing.
> 
> What I don't understand at this point is how hiding the ports behind
> a master device would buy us anything. We would still need to abstract
> the filtering capabilities of the ports at some level and hiding that
> behind existing tools seems to most convenient way.

I don't see much benefit from the master driver approach either.
We had something like that in the wireless space for a while, and it
mostly just caused confusion.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
