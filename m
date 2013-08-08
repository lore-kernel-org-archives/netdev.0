From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net] ipv6: do not create neighbor entries for local delivery
Date: Thu, 8 Aug 2013 21:01:36 +0200
Message-ID: <20130808190136.GE14001@order.stressinduktion.org>
References: <20130130082608.GA1604@minipsycho.orion> <CAATkVEzJgb+J-TAkTZCUbxLPj=b=wbOmsKbgNNimEfNaC8d0Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, mleitner@redhat.com,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	Joshua Hunt <johunt@akamai.com>
To: Debabrata Banerjee <dbavatar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39970 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966125Ab3HHTBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 15:01:38 -0400
Content-Disposition: inline
In-Reply-To: <CAATkVEzJgb+J-TAkTZCUbxLPj=b=wbOmsKbgNNimEfNaC8d0Aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 08, 2013 at 02:45:40PM -0400, Debabrata Banerjee wrote:
> On Wed, Jan 30, 2013 at 3:26 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> > From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> >
> > They will be created at output, if ever needed. This avoids creating
> > empty neighbor entries when TPROXYing/Forwarding packets for addresses
> > that are not even directly reachable.
> >
> > Note that IPv4 already handles it this way. No neighbor entries are
> > created for local input.
> >
> > Tested by myself and customer.
> >
> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> > Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> >
> > [...]
> 
> I'm not sure this patch is doing the right thing. It seems to break
> IPv6 loopback functionality, it is no longer equivalent to IPv4, as
> stated above. It doesn't just stop neighbor creation but it stops
> cached route creation. Seems like a scary change for a stable tree.
> See below:
> 
> $ ip -4 route show local
> local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1
> 
> This local route enables us to use the whole loopback network, any
> address inside 127.0.0.0/8 will work.
> 
> $ ping -c1 127.0.0.9
> PING 127.0.0.9 (127.0.0.9) 56(84) bytes of data.
> 64 bytes from 127.0.0.9: icmp_seq=1 ttl=64 time=0.012 ms
> 
> --- 127.0.0.9 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev = 0.012/0.012/0.012/0.000 ms
> 
> This also used to work equivalently for IPv6 local loopback routes:
> 
> $ ip -6 route add local 2001:::/64 dev lo
> $ ping6 -c1 2001::9
> PING 2001::9(2001::9) 56 data bytes
> 64 bytes from 2001::9: icmp_seq=1 ttl=64 time=0.010 ms
> 
> --- 2001::9 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev = 0.010/0.010/0.010/0.000 ms
> 
> However with this patch, this is very broken:
> 
> $ ip -6 route add local 2001::/64 dev lo
> $ ping6 -c1 2001::9
> PING 2001::9(2001::9) 56 data bytes
> ping: sendmsg: Invalid argument
> 
> --- 2001::9 ping statistics ---
> 1 packets transmitted, 0 received, 100% packet loss, time 0ms

Which kernel version are you using? Perhaps you miss another fix? It works for
me. Also I cannot find this patch in net-next?

Greetings,

  Hannes
