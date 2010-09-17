From: AIJAZ BAIG <aijazbaig1@gmail.com>
Subject: Re: problem with flowi structure
Date: Fri, 17 Sep 2010 11:10:09 +0530
Message-ID: <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com>
References: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com>
	<1284650768.3352.37.camel@edumazet-laptop>
	<AANLkTimo1AeBS3rpQj0KtZL15Ct-DGTQMBUsL8hrVNOL@mail.gmail.com>
	<1284652453.3352.38.camel@edumazet-laptop>
	<AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Nicola Padovano <nicola.padovano@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

Well..if u see the code, ull see that ip_route_output_key is a wrapper
around ip_route_output_flow which in turn internally calls
__ip_route_output_key. This later function tries to find a route for a
packet first by looking up the routing cache and then if it isnt found
there it  constructs a cache entry by calling its slow counterpart
which is ip_route_output_slow.

Now, the name tells u a lot. First ip_route_output_key tells u that
this function 'routes' an 'output' packet. An output packet normally
means that the packet is a locally generated packet. The routing (L3)
protocol being used is ip (ipv4 specifically) and key tells us that we
are specifying the key to be used to check the routing cache (since
the cache is organized as a hash and it needs a key to retrieve an
entry).

Thus all in all, the ip_route_output_key function is used to get a
route for an output packet either from the routing cache if an entry
is present or create one and update the cache accordingly.

Hope it helped.

Regards,
Aijaz

On 9/17/10, Nicola Padovano <nicola.padovano@gmail.com> wrote:
> ok, let's step back...
> what's the task of ip_route_output_key function ?
>
> --
> Nicola Padovano
> e-mail: nicola.padovano@gmail.com
> web: http://npadovano.altervista.org
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
