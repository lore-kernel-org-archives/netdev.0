From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Thu, 17 Feb 2005 22:23:02 +0100
Message-ID: <42150B36.5080609@trash.net>
References: <4214381F.5020507@trash.net> <20050217113654.GA10346@gondor.apana.org.au> <4214DF5B.3010608@trash.net> <20050217203805.GA4047@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050217203805.GA4047@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Thu, Feb 17, 2005 at 07:15:55PM +0100, Patrick McHardy wrote:
>  
>
>>I don't think this solves the inconsistency. By reuseing routes in tunnel
>>mode we allow routing by different criteria when the inner packet is headed
>>for the remote gateway. Your suggestion limits this a bit further, but we
>>can still have a situation where all packets going through a tunnel take
>>one path, except when the inner packet is heading for the remote gateway
>>itself.
>>    
>>
>
>That's right.  However, you should also look at it this way.  We start
>with a policy with a transport mode SA.  In order to protect the IP
>header we change it to use a tunnel mode SA with a host-to-host selector.
>With your patch this will change the route that the packet uses.
>

I don't consider this inconsistent, in fact it is consistent to what
happens with other tunnels. We could get the behaviour you want (my
patch + old behaviour for host-to-host tunnels) by looking at the
policy selector, but I would prefer to always reroute. The change
doesn't affect existing setups, as I said in my previous mail, it
doesn't work properly since __xfrm4_find_bundle() ignores tos/fwmark
and uses the route for src/dst that made the cache (first one used)
for all tos/fwmark values, even if other routes exist.

Regards
Patrick
