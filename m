From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] x_tables: Use also dev->ifalias for interface
 matching
Date: Mon, 12 Jan 2015 17:22:57 +0000
Message-ID: <20150112172257.GG17329@acer.localdomain>
References: <1421009571-5279-1-git-send-email-richard@nod.at>
 <1425960.ovH4s7sjue@rofl>
 <1421081514.4099.14.camel@edumazet-glaptop2.roam.corp.google.com>
 <2868544.UBk2Y85taW@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Weinberger <richard@nod.at>, davem@davemloft.net,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, john.fastabend@gmail.com,
	herbert@gondor.apana.org.au, vyasevic@redhat.com, jiri@resnulli.us,
	vfalico@gmail.com, therbert@google.com, edumazet@google.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	kadlec@blackhole.kfki.hu, pablo@netfilter.org, kay@vrfy.org,
	stephen@networkplumber.org
To: Patrick Schaaf <netdev@bof.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2868544.UBk2Y85taW@rofl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12.01, Patrick Schaaf wrote:
> On Monday 12 January 2015 08:51:54 Eric Dumazet wrote:
> > On Mon, 2015-01-12 at 17:39 +0100, Patrick Schaaf wrote:
> > > 
> > > Not to comment on the ifalias thing, which I think is unneccessary,
> > > too, but matching on interface names instead of only ifindex, is
> > > definitely needed, so that one can establish a full ruleset before
> > > interfaces even exist. That's good practise at boottime, but also
> > > needed for dynamic interface creation during runtime.
> > 
> > Please do not send html messages : Your reply did not reach the lists.
> 
> Sigh. Sorry...
> 
> > Then, all you mention could have been solved by proper userspace
> > support.
> > 
> > Every time you add an interface or change device name, you could change
> > firewalls rules if needed. Nothing shocking here.
> 
> That is totally impractical, IMO.
> 
> Interfaces come and go through many different actions. There's the admin 
> downing and upping stuff like bridges or bonds. There's stuff like libvirt / 
> KVM / qemu creating and destroying interfaces. In all these cases, in my 
> practise, I give the interfaces useful names to that I can prefix-match them 
> in iptables rules.
> 
> Dynamically modifying the ruleset for each such creation and destruction, 
> would be a huge burden. The base ruleset would need suitable "hooks" where 
> these rules were inserted (ordering matters!). The addition would hardly be 
> atomic (with traditional iptables, unless done by generating a whole new 
> ruleset and restoring). The programs (e.g. libvirt) would need to be able to 
> call out to these specially crafted rule generator scripts. The admin would 
> need to add them as pre/post actions to their static (manual) interface 
> configuration. Loading and looking at the ruleset before bringing up the 
> interface would be impossible.

devgroups seem like the best solution for this.
