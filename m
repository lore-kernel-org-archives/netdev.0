From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next] net: Convert LIMIT_NETDEBUG to
 net_dbg_ratelimited
Date: Mon, 10 Nov 2014 07:26:55 -0800
Message-ID: <1415633215.8868.4.camel@perches.com>
References: <1415230929.6634.38.camel@perches.com>
	 <20141106.151149.1321164537677873976.davem@davemloft.net>
	 <1415307221.21526.0.camel@perches.com>
	 <20141108.204202.2273082249078358608.davem@davemloft.net>
	 <1415560642.23530.43.camel@perches.com> <5460CB43.4050008@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Remi Denis-Courmont <courmisch@gmail.com>
To: nicolas.dichtel@6wind.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5460CB43.4050008@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-11-10 at 15:27 +0100, Nicolas Dichtel wrote:
> Le 09/11/2014 20:17, Joe Perches a =E9crit :
> > Use the more common dynamic_debug capable net_dbg_ratelimited
> > and remove the LIMIT_NETDEBUG macro.
> >
> > This may have some negative impact on messages that were
> > emitted at KERN_INFO that are not not enabled at all unless
> > DEBUG is defined or dynamic_debug is enabled.  Even so,
> > these messages are now _not_ emitted by default.
> >
> > This eliminates the use of the net_msg_warn sysctl
> > "/proc/sys/net/core/warnings".
[]
> > diff --git a/include/net/sock.h b/include/net/sock.h
[]
> > @@ -2276,13 +2276,7 @@ bool sk_ns_capable(const struct sock *sk,
> >   bool sk_capable(const struct sock *sk, int cap);
> >   bool sk_net_capable(const struct sock *sk, int cap);
> >
> > -/*
> > - *	Enable debug/info messages
> > - */
> > -extern int net_msg_warn;
> > -#define LIMIT_NETDEBUG(fmt, args...) \
> > -	do { if (net_msg_warn && net_ratelimit()) printk(fmt,##args); } w=
hile(0)
> > -
> > +extern int net_msg_warn;	/* Unused, but still a sysctl */
> Why not removing this variable from this header and from net/core/uti=
ls.c?
> Just declaring a static variable in net/core/sysctl_net_core.c should=
 be enough.
> Am I missing something?

No.  It's reasonable to remove its EXPORT_SYMBOL use too.

=46irst let's see if there are any objections to the removal.
