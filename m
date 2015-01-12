From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] x_tables: Use also dev->ifalias for interface
 matching
Date: Mon, 12 Jan 2015 08:46:08 -0800
Message-ID: <1421081168.4099.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421009571-5279-1-git-send-email-richard@nod.at>
	 <1421009571-5279-3-git-send-email-richard@nod.at>
	 <1421078666.4099.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LSU.2.11.1501121731510.25482@nerf60.vanv.qr>
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
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.11.1501121731510.25482@nerf60.vanv.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-12 at 17:32 +0100, Jan Engelhardt wrote:
> On Monday 2015-01-12 17:04, Eric Dumazet wrote:
> >
> >iptables should have used ifindex [for interface matching],
> >it[']s sad we allowed the substring match in first place.
> 
> How would you solve interface name wildcards with ifindices?
> (They come in handy if you have something like lots of tun+/veth+
> interfaces from openvpn/lxc.)


This is what I said : "it[']s sad we allowed the substring match in
first place."

This obviously referred to wildcards, in the in/out interface match for
every _single_ rule, consuming 64 bytes of memory per rule and per cpu !
Which is absolutely crazy in term of memory usage.

Matching tun+ or whatever could easily be done by a match (-m ...),
because you can factorize this quite easily (called once for a group of
rules)
