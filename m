From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Ambiguities in TCP/IP - firewall bypassing (fwd)
Date: Wed, 30 Oct 2002 19:16:50 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210301911510.12727-100000@netcore.fi>
References: <20021020063535.A6016@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20021020063535.A6016@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks.

Needless to say I belive this is a big problem.

That's because about all firewalls/packet filters except Linux (possibly
due to the fact that there is no "established" except in full stateful
matching) -- checked Cisco, Juniper, BSD ipfw -- seem to treat
"established" as "ack|rst", and SYN+RST passes through them like a hot
knife in the butter.

On Sun, 20 Oct 2002, Andi Kleen wrote:

> On Sat, Oct 19, 2002 at 02:38:56PM +0300, Pekka Savola wrote:
> > See the thread on bugtraq.
> > 
> > Linux 2.4.19 initiates TCP handshake with SYN and RST bits set.  SYN with 
> > _RST_ seems like a total nonsense (SYN with FIN might even be useful for 
> > stuff like T/TCP) but I guess the spec didn't take any stance on that..
> 
> Here is a patch to fix it for 2.4.19.
> 
> 
> --- linux/net/ipv4/tcp_input.c-o	2002-10-15 17:24:53.000000000 +0200
> +++ linux/net/ipv4/tcp_input.c	2002-10-20 06:34:05.000000000 +0200
> @@ -3664,6 +3664,9 @@
>  		goto discard;
>  
>  	case TCP_LISTEN:
> +		if(th->rst) 
> +			goto discard;
> +
>  		if(th->ack)
>  			return 1;
>  
> 
> 
> -Andi
> 
> 

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
