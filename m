From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPsec xfrm resolution
Date: Sat, 19 Feb 2005 20:53:33 +0100
Message-ID: <4217993D.4070107@trash.net>
References: <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au> <42152841.5000707@trash.net> <20050218100854.GA19427@gondor.apana.org.au> <4216D6B4.5070901@trash.net> <20050219092314.GA8153@gondor.apana.org.au> <42173125.3040505@trash.net> <20050219183202.GA10773@gondor.apana.org.au> <421789AF.4020705@trash.net> <20050219190333.GA22166@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050219190333.GA22166@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Sat, Feb 19, 2005 at 07:47:11PM +0100, Patrick McHardy wrote:
>  
>
>>>That's a bug.  How can you forward packets properly if the tunnel mode
>>>SA is missing?
>>>      
>>>
>>Using normal routing. What meaning would "optional" have otherwise ?
>>If the encapsulation has to be done, the user shouldn't mark the SA
>>as optional in my opinion.
>>    
>>
>
>In that case you can't mark IPCOMP SAs as optional in this scenario
>which is the most common application of optional:
>
>IPCOMP(tunnel) -- ESP(transport)
>  
>
I've checked KAME, it also skips IPSEC_LEVEL_USE SAs if they aren't present.
IPCOMP in tunnel mode is a special case. It wants to express more than just
"optional". It means to say "use SA if present and some things wrt. size 
apply,
otherwise use a similar SA with proto=IPIP". One of both has to be used, and
this is what "optional" can't express. The current method is to use the IPIP
SA automatically created with the IPCOMP SA when the compressed size exceeds
the uncompressed size, but it doesn't handle a missing SA. This suggests we
need to special-case tunnel mode IPCOMP in xfrm_tmpl_resolve() and either
ignore "optional" for IPIP tunnel mode SAs or create them on demand.

Regards
Patrick
