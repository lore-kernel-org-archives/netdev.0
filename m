From: jamal <hadi@cyberus.ca>
Subject: Re: Problem with IPSEC tunnel mode
Date: Sun, 24 Apr 2005 18:08:47 -0400
Message-ID: <1114380527.7669.142.camel@localhost.localdomain>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au>
	 <200504221522.49403.wolfgang.walter@studentenwerk.mhn.de>
	 <1114278545.7669.75.camel@localhost.localdomain>
	 <200504232303.35549.wolfgang.walter@studentenwerk.mhn.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
In-Reply-To: <200504232303.35549.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-23-04 at 23:03 +0200, Wolfgang Walter wrote:

> 
> SPD is indeed also a sort of firewall. You can use it to construct i.e. a 
> vpn-gateway and forbid any non-vpn-traffic entering or leaving.
> 

So i think design intent must have been to map these to the
netfilter/iptables hooks - fwd/in/out hooks. 

> How the SPD is implemented is of course not specified. I think KLIPS use a 
> mixing of routing and netfilter and "ipsec-netdevices" to realise the SPD.
> 

It could certainly be any applicable classifier that can map at least
the 6 tuples {src/dst IP, src/dst port, proto, netdevice}. 

> My personal view is that 2.6 native SPD is better. Its easier to understand 
> and protect i.e. vpn-gateways.

Except it introduces yet another firewall scheme. We should look at
unifying these schemes. Both the input/fwding can be derived at the
ingress. 

> Using selectors other than src, dst in the SPD is tricky, by the way, because 
> of fragments. Say a rule selects packets from a to b with protocol tcp and 
> dst-port 80 to be sent through a tunnel you must have an extra rule (and 
> tunnel) for the fragments (and all fragments are tunneled then).
> 
>
> Maybe more complex selectors should be realised by netfilter, a module which 
> can mark packets. And SPD uses that mark. Then statefull policies are 
> possible, i.e.
> 

I think that it is probably the best path forward - i suppose this being
the first incarnation of native ipsec this could be seen as a lesson.
 
> I don't know if linux handles ICMP traffic well, often one must check the 
> payload against the SPD. I had no time yet to do some tests.
> 

from the code it should work just fine.

cheers,
jamal
