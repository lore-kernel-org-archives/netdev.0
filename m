From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Bug in ipv6_ifa_notify?
Date: Tue, 09 Nov 2004 09:57:59 -0500 (EST)
Message-ID: <20041109.095759.109272072.yoshfuji@linux-ipv6.org>
References: <20041108121040.GA3618@gondor.apana.org.au>
	<20041108203741.GA993@gondor.apana.org.au>
	<20041109114839.GA1942@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, acme@conectiva.com.br, netdev@oss.sgi.com,
        jgarzik@pobox.com, buytenh@wantstofly.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20041109114839.GA1942@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041109114839.GA1942@gondor.apana.org.au> (at Tue, 9 Nov 2004 22:48:39 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Tue, Nov 09, 2004 at 07:37:41AM +1100, herbert wrote:
> > 
> > Well I've found a way for this to occur, but I must say that it is
> > fairly unlikely.  When you bring the interface down, addrconf_ifdown
> > will try to to delete the addrconf timer and then notify DELADDR.
> > Since it doesn't wait for the timer to complete, it might still be
> > executing.  Therefore it is possible to have a NEWADDR after a DELADDR
> > event.
> 
> The attractive thing about this theory is that it is an SMP-only
> race.  This could explain why only Jeff/Lennert are seeing it.
> 
> Jeff/Lennert, could you please go back to 2.6.9, and then apply
> this patch? If this warning triggers, then that would confirm
> this theory.

I think this only happens when you shut down interface while DAD;
for example, "ifup eth0 &; ifdown eth0" or something like that.

--yoshfuji
