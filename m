From: jamal <hadi@cyberus.ca>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 08:14:44 -0400
Message-ID: <1114172084.7679.15.camel@localhost.localdomain>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au>
	 <20050421235802.GB10451@gondor.apana.org.au>
	 <1114129099.10572.24.camel@localhost.localdomain>
	 <200504221342.10675.wolfgang.walter@studentenwerk.mhn.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-M5oQ++3HCrAQcioPTK1S"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
In-Reply-To: <200504221342.10675.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-M5oQ++3HCrAQcioPTK1S
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2005-22-04 at 13:42 +0200, Wolfgang Walter wrote:
> Am Freitag, 22. April 2005 02:18 schrieb jamal:
[..]
> > So i was wondering whether they OUT shouldnt be just a duplicate of
> > FWD (instead FWD seems to be the dup of IN). Look at that sample i
> > posted - all his policies look like that. What gives? Why are the IN and
> > FWD exactly the same? bug in racoon/setkey?

> No. XFRM_POLICY_IN is only checked for incoming packets which are delivered 
> locally.
> 

For encrypted packets

> XFRM_POLICY_FWD is checked for incoming packets which are routed.
> 

For non-encrypted packets to be forwarded.

> That our XFRM_POLICY_IN matches XFRM_POLICY_FWD is more for convenience: if a 
> subnet is connected directly to a router we want to treat the interface 
> address of the router itself the same way. Instead of constructing special 
> rules which exactly match the interface address we simply use the same rule 
> as for forwarding.
> 

Ok, so it was design intent then.


> XFRM_POLICY_OUT ist checked for every outgoing packet, be it locally generated 
> be it routed (which is different from netfilter).
> 
> This asymmetry is a little bit inconsequent. Probably one should really have 
> XFRM_POLICY_FWD_IN and XFRM_POLICY_FWD_OUT. But XFRM_POLICY_OUT would mainly 
> be a copy of XFRM_POLICY_FWD_OUT then, I think.
> 

I did notice racoon or even setkey (version 0.5) for some rules (need to investigate) 
would install two policy rules when i installed only one i.e racoon will install 
one in OUT and other in FWD direction. 

Example script and setkey -DP output attached. In this case i install
two rules, but for one of them an extra rule is installed. Actually the
pattern is quiet repeatable as you add more rules. This may also be what
is happening to you maybe?

cheers,
jamal

--=-M5oQ++3HCrAQcioPTK1S
Content-Disposition: attachment; filename=sample.conf
Content-Type: text/plain; name=sample.conf; charset=utf-8
Content-Transfer-Encoding: 7bit

#!/usr/sbin/setkey -f

# Flush the SAD and SPD
flush;
spdflush;

spdadd 192.168.3.10 192.168.2.100 any -P out ipsec
           esp/transport//require
           ah/transport//require;

spdadd 192.168.2.100 192.168.3.10 any -P in ipsec
           esp/transport//require
           ah/transport//require;
	

--=-M5oQ++3HCrAQcioPTK1S
Content-Disposition: attachment; filename=setkey_output
Content-Type: text/plain; name=setkey_output; charset=utf-8
Content-Transfer-Encoding: 7bit

192.168.2.100[any] 192.168.3.10[any] any
	in ipsec
	esp/transport//require
	ah/transport//require
	created: Apr 22 08:06:28 2005  lastused:                     
	lifetime: 0(s) validtime: 0(s)
	spid=8 seq=2 pid=8236
	refcnt=1
192.168.3.10[any] 192.168.2.100[any] any
	out ipsec
	esp/transport//require
	ah/transport//require
	created: Apr 22 08:06:28 2005  lastused:                     
	lifetime: 0(s) validtime: 0(s)
	spid=1 seq=1 pid=8236
	refcnt=1
192.168.2.100[any] 192.168.3.10[any] any
	fwd ipsec
	esp/transport//require
	ah/transport//require
	created: Apr 22 08:06:28 2005  lastused:                     
	lifetime: 0(s) validtime: 0(s)
	spid=18 seq=0 pid=8236
	refcnt=1

--=-M5oQ++3HCrAQcioPTK1S--
