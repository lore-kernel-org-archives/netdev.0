From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Disabling IPv6 accept_ra on just some interface
Date: Mon, 27 Oct 2003 15:05:42 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310271502110.9110-100000@netcore.fi>
References: <20031027.215853.103522470.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: netdev@oss.sgi.com, <sekiya@wide.ad.jp>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031027.215853.103522470.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Oct 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <Pine.LNX.4.44.0310231457110.3347-100000@netcore.fi> (at Thu, 23 Oct 2003 15:22:47 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:
> > So, my thought (comments welcome) is:
> > 
> >  1) when accept_ra changes from 0 -> 1, initiate the route 
> >     solicitation process, likewise as one would when the interface is 
> >     brought up.
> > 
> >     Makes sense?
> > 
> >  2) (probably not a good idea, but some food for thought..) when accept_ra 
> >     changes from 1 -> 0, delete any autoconfigured routes or
> >     prefixes.  (could be ugly / dangerous..)
> 
> Well, we'd propose to have another config "send_rs" or something like that
> because accept_ra is also effective against unsolicited RAs.
> It, "send_rs," tells kernel to start sending RS 
> when the variable is changed 0 to 1 and/or 
> when interface is going up.

I don't have any major objections to this model, I'm just worried that it
might make the configuration more complex (we already have accept_ra and
"autoconf" toggles which are confusing enough without documentation :-)
with little gain.

That is, is there any case when you'd want to accept an RA but *not* send 
RS?  I fail to see clear applicability for this, hence my proposal to 
overload accept_ra :-)

> Assume the node has eth0 and eth1.
> Operation will be something like the following.
> 
> If you want to listen RA and to send RS on some interfaces,
>  sysctl -w net.ipv6.conf.default.accept_ra=0
>  sysctl -w net.ipv6.conf.default.send_rs=0
>  ifup -a
>  sysctl -w net.ipv6.conf.eth0.accept_ra=1
>  sysctl -w net.ipv6.conf.eth0.send_rs=1
> 
> If you want to listen RA on all interfaces, but do not want to send RS on 
> some of them, 
>  sysctl -w net.ipv6.conf.default.accept_ra=1
>  sysctl -w net.ipv6.conf.default.send_rs=0
>  ifup -a
>  sysctl -w net.ipv6.cont.eth0.send_rs=1
> 
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
