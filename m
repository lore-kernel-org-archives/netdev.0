From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.7-rc3-mm2 2/5] via-velocity: uniformize use of OWNED_BY_NIC
Date: Fri, 18 Jun 2004 23:42:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618234241.A21510@electric-eye.fr.zoreil.com>
References: <20040618221014.A15640@electric-eye.fr.zoreil.com> <20040618221142.A20210@electric-eye.fr.zoreil.com> <40D3584A.9010009@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, alan@redhat.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D3584A.9010009@pobox.com>; from jgarzik@pobox.com on Fri, Jun 18, 2004 at 05:02:02PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
> Francois Romieu wrote:
[...]
> > +static inline void velocity_give_rx_desc(struct rx_desc *rd)
> > +{
> > +	*(u32 *)&rd->rdesc0 = 0;
> > +	rd->rdesc0.owner = cpu_to_le32(OWNED_BY_NIC);
> > +}
> 
> The patch itself is OK, and I will merge, but I wonder:
> 
> isn't a wmb() needed perhaps?

/me scratches head...

Ok, everything should be fine with a change in velocity_give_many_rx_descs():
[...]
        if (vptr->rd_filled < 4)
                return;

<insert a wmb() here>

        unusable = vptr->rd_filled | 0x0003;


I'll queue that for the next serie.

--
Ueimor
