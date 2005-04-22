From: jamal <hadi@cyberus.ca>
Subject: Re: Problem with IPSEC tunnel mode
Date: Thu, 21 Apr 2005 20:18:19 -0400
Message-ID: <1114129099.10572.24.camel@localhost.localdomain>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au>
	 <200504211640.16742.wolfgang.walter@studentenwerk.mhn.de>
	 <20050421214618.GA29991@gondor.apana.org.au>
	 <1114127419.10572.4.camel@localhost.localdomain>
	 <20050421235802.GB10451@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050421235802.GB10451@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-22-04 at 09:58 +1000, Herbert Xu wrote:
> On Thu, Apr 21, 2005 at 07:50:19PM -0400, jamal wrote:
> > What was the reason there exist a FWD direction in the policies?
> 
> You should really ask Alexey about that :) I myself had the same
> question when I first started in this area.  However, since it
> has been present since the very beginning and people are already
> relying on it, we will have to live with it.
> 

I am sure if Alexey did it theres a good reason - I am not sure i get
it. CCing mr Kuznet.

> > Also - shouldnt the FWD policies closely match the OUT ones instead of
> > the IN direction (browsing the forwarding code)? i.e
> > does this look odd to you (picking a sample from Wolfgangs output):
> 
> The FWD policies are analogous to the FORWARD table in netfilter.
> The FWD policies apply to forwarded packet, meaning packets that
> end up in ip_forward instead of ip_local_deliver.  The IN policies
> only apply to packets that end up in ip_local_deliver.
> 

Heres what confused me when i browsed:
looking at ip_forward() - it does a xfrm4_policy_check(NULL,
XFRM_POLICY_FWD, skb)  - this leads to a flow cache creation based on
FWD direction. Later on in the path (still in ip_forward)
xfrm4_route_forward() gets invoked which does a flow_cache build again
based on XFRM_POLICY_OUT. 
So i was wondering whether they OUT shouldnt be just a duplicate of 
FWD (instead FWD seems to be the dup of IN). Look at that sample i
posted - all his policies look like that. What gives? Why are the IN and
FWD exactly the same? bug in racoon/setkey?

cheers,
jamal
