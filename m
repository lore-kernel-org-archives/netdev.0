From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] x_tables: Use also dev->ifalias for interface
 matching
Date: Mon, 12 Jan 2015 08:51:54 -0800
Message-ID: <1421081514.4099.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421009571-5279-1-git-send-email-richard@nod.at>
	 <1421009571-5279-3-git-send-email-richard@nod.at>
	 <1421078666.4099.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425960.ovH4s7sjue@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>, davem@davemloft.net,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, john.fastabend@gmail.com,
	herbert@gondor.apana.org.au, vyasevic@redhat.com, jiri@resnulli.us,
	vfalico@gmail.com, therbert@google.com, edumazet@google.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	kay@vrfy.org, stephen@networkplumber.org
To: Patrick Schaaf <netdev@bof.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425960.ovH4s7sjue@rofl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-12 at 17:39 +0100, Patrick Schaaf wrote:
> > iptables should have used ifindex, its sad we allowed the substring
> 
> > match in first place.
> 
>  
> 
> Not to comment on the ifalias thing, which I think is unneccessary,
> too, but matching on interface names instead of only ifindex, is
> definitely needed, so that one can establish a full ruleset before
> interfaces even exist. That's good practise at boottime, but also
> needed for dynamic interface creation during runtime.
> 
>  
> 
> A pure ifindex-during-packet-inspection approach might still work, but
> the ruleset must IMO keep the interface names. Maybe register them in
> a hash, keyed by name, with values an ifindex or ifindex set (for
> wildcard names), plus a reverse mapping from active ifindices to all
> places in these hash values where an ifindex has been remembered. On
> interface creation / destruction that structure could then be updated,
> and active packet filtering rules would refer to (and keep a refcount
> on) specific hash elements.
> 
Please do not send html messages : Your reply did not reach the lists.

Then, all you mention could have been solved by proper userspace
support.

Every time you add an interface or change device name, you could change
firewalls rules if needed. Nothing shocking here.

The ruleset can indeed mention interface names, but the kernel part
really should not care about names, which are a 'human' convenient way
to represent things.
