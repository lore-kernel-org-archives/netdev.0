From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Super TSO
Date: Wed, 18 May 2005 12:57:09 -0700 (PDT)
Message-ID: <20050518.125709.112621421.davem@davemloft.net>
References: <20050517.192416.108741581.davem@davemloft.net>
	<m1fywk645i.fsf@muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de
In-Reply-To: <m1fywk645i.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@muc.de>
Date: Wed, 18 May 2005 15:43:21 +0200

> > @@ -674,59 +653,274 @@ unsigned int tcp_sync_mss(struct sock *s
> >   * cannot be large. However, taking into account rare use of URG, this
> >   * is not a big flaw.
> >   */
> > +static inline u32 compute_xmit_cache(u32 mss, int sacks, int tso_enabled)
> > +{
> > +	u32 ret = (mss << 16) | sacks;
> 
> 16bit MSS? How does that deal with jumbopackets on IPv6?
> While the MSS option is also 16bit it is legal to construct bigger
> datagrams when no MSS option was exchanged.

It doesn't, and neither does the existing code.  I know it needs
to be fixed, thanks for reminding me.
