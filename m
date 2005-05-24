From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 17:26:37 +0900
Message-ID: <4292E53D.7030805@miyazawa.org>
References: <E1DaTeW-00085B-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "YOSHIFUJI Hideaki / ????" <yoshfuji@linux-ipv6.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DaTeW-00085B-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

Without our patch, the dst_check in xfrm_bundle_ok returns NULL
when it is IPv6 route, then xfrm_bundle_ok always fails.
xfrm_lookup calls xfrm_bundle_ok via stalbe_bundle so that
it goes to restart and recreate bundles.
But stale_bundle always fails. It results the infinite loop accordingly.

This bug only occurs on IPv6. IPv4 works correctly without the patch.

I can not show the evidence of the infinite loop
because the kernel freezes :-<


Herbert Xu wrote:
> YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> 
>>From: Kazunori Miyazawa <kazunori@miyazawa.org>
>>
>>[XFRM] Call dst_check() with appropriate cookie.
>>
>>This fixes infinite loop issue with IPv6 tunnel mode.
> 
> 
> Can someone please tell me where this infinite loop is?
> 
> Thanks,


--
Kazunori Miyazawa
