From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Check against correct policy list in ip_forward/ip6_forward
Date: Mon, 18 Oct 2004 22:34:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417428CF.2050802@trash.net>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au> <4172F1AB.4020305@trash.net> <20041017231258.GA29294@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041017231258.GA29294@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>
>Well it's too late to change the default policy.  People rely on the
>default policy being allow so changing it will wreak havoc.  Even if
>you do it only for packets with an IPsec encapsulation by checking
>skb->sp it may still break people who use manual keying and rely on
>the property that you can always add optional SAs.
>
You're right.

>  More importantly that it'll stick out like a sore thumb in terms of
>
 > its semantics.

__xfrm_policy_check already rejects packets without a matching policy
and skb->sp set, but it is skipped while the policy list is empty.
What, from a semantics point of view, would be wrong with making
xfrm_policy_check behave the same way ?

>
>So let's just fix racoon.
>
Agreed. I have a patch I'm currently testing. Judging from a quick
grep isakmpd also doesn't add forward policies.

Regards
Patrick
