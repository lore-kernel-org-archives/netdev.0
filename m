From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Fri, 18 Feb 2005 00:02:27 +0100
Message-ID: <42152283.4030800@trash.net>
References: <4214381F.5020507@trash.net> <20050217113654.GA10346@gondor.apana.org.au> <4214DF5B.3010608@trash.net> <20050217203805.GA4047@gondor.apana.org.au> <42150B36.5080609@trash.net> <20050217221031.GA4554@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050217221031.GA4554@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Thu, Feb 17, 2005 at 10:23:02PM +0100, Patrick McHardy wrote:
>  
>
>>I don't consider this inconsistent, in fact it is consistent to what
>>happens with other tunnels. We could get the behaviour you want (my
>>    
>>
>
>Well we'll have to disagree on that.  IMHO the flow with the internal
>addresses equal to the external addresses over a tunnel mode SA should
>be treated the same as that over a transport mode SA.
>  
>

Maybe Dave can help resolve this with a third opinion.

>>patch + old behaviour for host-to-host tunnels) by looking at the
>>policy selector, but I would prefer to always reroute. The change
>>doesn't affect existing setups, as I said in my previous mail, it
>>doesn't work properly since __xfrm4_find_bundle() ignores tos/fwmark
>>and uses the route for src/dst that made the cache (first one used)
>>for all tos/fwmark values, even if other routes exist.
>>    
>>
>
>Are you sure that it doesn't change existing behaviour? Suppose that
>I had a socket bound to a specific device, doesn't the current code
>use that device as long as we're sending to the remote IPsec gateway?
>  
>

You're right, if no other route using same src/dst/oif made the cache
first it will be used.

Regards
Patrick
