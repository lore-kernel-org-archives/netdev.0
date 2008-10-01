From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v6 04/16] selinux: Better local/forward check in selinux_ip_postroute()
Date: Wed, 1 Oct 2008 12:41:48 -0400
Message-ID: <200810011241.48776.paul.moore@hp.com>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125613.17132.70639.stgit@flek.lan> <alpine.LRH.1.10.0810011141180.5277@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.1.10.0810011141180.5277@tundra.namei.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 30 September 2008 9:43:12 pm James Morris wrote:
> On Tue, 16 Sep 2008, Paul Moore wrote:
> > It turns out that checking to see if skb->sk is NULL is not a very
> > good indicator of a forwarded packet as some locally generated
> > packets also have skb->sk set to NULL.  Fix this by not only
> > checking the skb->sk field but also the IP[6]CB(skb)->flags field
> > for the IP[6]SKB_FORWARDED flag.  While we are at it, we are
> > calling selinux_parse_skb() much earlier than we really should
> > resulting in potentially wasted cycles parsing packets for
> > information we might no use; so shuffle the code around a bit to
> > fix this.
> >
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
>
> Acked-by: James Morris <jmorris@namei.org>
>
> (Wow, this code is getting complex... :-)

Yeah, it is pretty surprising too (at least to me anyway).  I beginning 
to think our common case is the existence of corner cases :)

-- 
paul moore
linux @ hp
