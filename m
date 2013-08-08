From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net] ipv6: do not create neighbor entries for local delivery
Date: Thu, 8 Aug 2013 21:16:53 +0200
Message-ID: <20130808191653.GG14001@order.stressinduktion.org>
References: <20130130082608.GA1604@minipsycho.orion> <CAATkVEzJgb+J-TAkTZCUbxLPj=b=wbOmsKbgNNimEfNaC8d0Aw@mail.gmail.com> <20130808190136.GE14001@order.stressinduktion.org> <5203EB4C.5020905@redhat.com> <20130808190624.GF14001@order.stressinduktion.org> <5203ED60.30108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Debabrata Banerjee <dbavatar@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	Joshua Hunt <johunt@akamai.com>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40011 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966174Ab3HHTQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 15:16:55 -0400
Content-Disposition: inline
In-Reply-To: <5203ED60.30108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 08, 2013 at 04:11:28PM -0300, Marcelo Ricardo Leitner wrote:
> Em 08-08-2013 16:06, Hannes Frederic Sowa escreveu:
> >On Thu, Aug 08, 2013 at 04:02:36PM -0300, Marcelo Ricardo Leitner wrote:
> >>Em 08-08-2013 16:01, Hannes Frederic Sowa escreveu:
> >>>On Thu, Aug 08, 2013 at 02:45:40PM -0400, Debabrata Banerjee wrote:
> >>>>On Wed, Jan 30, 2013 at 3:26 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> >>>>>From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> >>>>I'm not sure this patch is doing the right thing. It seems to break
> >>>>IPv6 loopback functionality, it is no longer equivalent to IPv4, as
> >>>>stated above. It doesn't just stop neighbor creation but it stops
> >>>>cached route creation. Seems like a scary change for a stable tree.
> >>>>See below:
> >>>>
> >>>>$ ip -4 route show local
> >>>>local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1
> >>>>
> >>>>This local route enables us to use the whole loopback network, any
> >>>>address inside 127.0.0.0/8 will work.
> >>>>
> >>>>$ ping -c1 127.0.0.9
> >>>>PING 127.0.0.9 (127.0.0.9) 56(84) bytes of data.
> >>>>64 bytes from 127.0.0.9: icmp_seq=1 ttl=64 time=0.012 ms
> >>>>
> >>>>--- 127.0.0.9 ping statistics ---
> >>>>1 packets transmitted, 1 received, 0% packet loss, time 0ms
> >>>>rtt min/avg/max/mdev = 0.012/0.012/0.012/0.000 ms
> >>>>
> >>>>This also used to work equivalently for IPv6 local loopback routes:
> >>>>
> >>>>$ ip -6 route add local 2001:::/64 dev lo
> >>>>$ ping6 -c1 2001::9
> >>>>PING 2001::9(2001::9) 56 data bytes
> >>>>64 bytes from 2001::9: icmp_seq=1 ttl=64 time=0.010 ms
> >>>>
> >>>>--- 2001::9 ping statistics ---
> >>>>1 packets transmitted, 1 received, 0% packet loss, time 0ms
> >>>>rtt min/avg/max/mdev = 0.010/0.010/0.010/0.000 ms
> >>>>
> >>>>However with this patch, this is very broken:
> >>>>
> >>>>$ ip -6 route add local 2001::/64 dev lo
> >>>>$ ping6 -c1 2001::9
> >>>>PING 2001::9(2001::9) 56 data bytes
> >>>>ping: sendmsg: Invalid argument
> >>>>
> >>>>--- 2001::9 ping statistics ---
> >>>>1 packets transmitted, 0 received, 100% packet loss, time 0ms
> >>>
> >>>Which kernel version are you using? Perhaps you miss another fix? It 
> >>>works
> >>>for
> >>>me. Also I cannot find this patch in net-next?
> >>
> >>It wasn't needed/applied as the route cache was removed.
> >
> >Do you mean the rt->n(eighbour) removal? There was no removal of a route 
> >cache
> >in IPv6 land. The cache is merely in the routing table itself.
> 
> Yes, my bad, sorry. s/route/neighour/. It was discussed on this thread:
> http://article.gmane.org/gmane.linux.network/255318
> 
> "Note also that YOSHIFUJI Hideaki's patches to remove the cached neighbour
> entirely from ipv6 routes will have the same effect, so your patch won't
> be needed."

Ok, thanks!

But it somehow managed to get into stable kernels, nor? Kernels after rt->n
removal should not be affected. At least the example above works on my
net-next kernel correctly.

Greetings,

  Hannes
