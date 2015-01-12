From: Patrick Schaaf <netdev@bof.de>
Subject: Re: [PATCH 2/3] x_tables: Use also dev->ifalias for interface matching
Date: Mon, 12 Jan 2015 18:41:42 +0100
Message-ID: <2245326.CTMNrtX3Ao@rofl>
References: <1421009571-5279-1-git-send-email-richard@nod.at> <2868544.UBk2Y85taW@rofl> <20150112172257.GG17329@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
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
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150112172257.GG17329@acer.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 January 2015 17:22:57 Patrick McHardy wrote:
> On 12.01, Patrick Schaaf wrote:
> >
> > Interfaces come and go through many different actions. There's the admin
> > downing and upping stuff like bridges or bonds. There's stuff like libvirt
> > / KVM / qemu creating and destroying interfaces. In all these cases, in
> > my practise, I give the interfaces useful names to that I can
> > prefix-match them in iptables rules.
> > 
> > Dynamically modifying the ruleset for each such creation and destruction,
> > would be a huge burden. The base ruleset would need suitable "hooks" where
> > these rules were inserted (ordering matters!). The addition would hardly
> > be
> > atomic (with traditional iptables, unless done by generating a whole new
> > ruleset and restoring). The programs (e.g. libvirt) would need to be able
> > to call out to these specially crafted rule generator scripts. The admin
> > would need to add them as pre/post actions to their static (manual)
> > interface configuration. Loading and looking at the ruleset before
> > bringing up the interface would be impossible.
> 
> devgroups seem like the best solution for this.

Could be, technically.

Is there devgroup support in libvirt, ifcfg, whatever other distros use for 
their static interface configuration? Or, do I again have to write pre/post 
scripts to set devgroups? Wouldn't bother me too much nowadays, I've automated 
that for ifcfg style stuff in my production environment a year ago, but it's 
something an admin must actively manage...

There is other stuff, apart from libvirt, that creates and destroys interfaces 
on the fly. From my production environment, there's at least keepalived, which 
creates macvlan interfaces on the fly for VRRP VMAC support. I can configure 
the name for that, but nothing else, nor can I call a script pre/post for 
that. And my iptables rules on that boxen _do_ match specially on these 
interfaces.

Gooling a bit around does not immediately turn up any good documentation on it 
at all (four year old iproute2 commits, once I give that as a search term 
too?). Looks very sketchy (although the fundamental idea is clear to me. I'm 
looking through the normal admin practise lens....)

best regards
  Patrick
