From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Sat, 18 Sep 2004 08:50:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918.085003.77842779.yoshfuji@linux-ipv6.org>
References: <E1C8I2m-0005BS-00@gondolin.me.apana.org.au>
	<20040917.231127.114842301.yoshfuji@linux-ipv6.org>
	<20040917153536.6acec52e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040917153536.6acec52e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20040917153536.6acec52e.davem@davemloft.net> (at Fri, 17 Sep 2004 15:35:36 -0700), "David S. Miller" <davem@davemloft.net> says:

> Now all these call sites must pass 2 more parameters when
> calling ip_route_output_flow() than when they called
> ip_route_output_key() with only 2 parameters.

Okay, let me explain.
Honestly speaking, I had (at least) 4 options.

 1. change two functions (_key and _flow)
    - maintenancability issues
 2. David's one
    - maintenancability will be improved
    - maintains exported symbols for binary-only modules.
    - more function call and more stack usage.
 3. inlined __ip_route_output_flow() + ip_route_output_flow(), ip_route_output_key
    - maintenancability will be improved
    - breaks binary-only modules.
    - code size.
 4. migrate completely (my one)
    - maintenancability will be improved
    - breaks binary-only modules.
    - best stack usage, minimum function call, code size.
    - changes more places.

> Let's redo this first patch, putting ip_route_output_key()
> into net/ipv4/route.c, and have that function pass the
> "NULL, 0" final 2 args to ip_route_output_flow().

This increases function calls and uses more stack.
It seemd downgrade to me.
This is the reason I did not make such patch.


> And you therefore could have combined both efforts into
> one simple changeset looking like this, which is what I'm
> checking into my tree:

THANK YOU.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
