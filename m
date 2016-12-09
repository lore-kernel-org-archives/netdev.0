From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next v2] dsa:mv88e6xxx: dispose irq mapping for
 chip->irq
Date: Fri, 9 Dec 2016 19:00:29 +0100
Message-ID: <20161209180029.GK9923@lunn.ch>
References: <1481106907-30908-1-git-send-email-volodymyr.bendiuga@westermo.se>
 <20161207141144.GJ18817@lunn.ch>
 <4388a669-b425-97e0-346b-6b20f7f47f86@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, volodymyr.bendiuga-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Volodymyr Bendiuga <volodymyr.bendiuga-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4388a669-b425-97e0-346b-6b20f7f47f86-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2016 at 05:40:12PM +0100, Volodymyr Bendiuga wrote:
> Yes, most of the users of of_irq_get() do not use irq_dispose_mapping().
> 
> But some of them do (some irq chips), and I believe the correct way
> of doing this is to
> 
> dispose irq mapping, as the description for this function says that
> it unmaps
> 
> the irq, which is mapped by of_irq_parse_and_map(). Not disposing
> irq might not make
> 
> any affect on most drivers, but some, that get EPROBE_DEFER error do
> need to dispose.
> 
> This is what I get when I run the code.
> 
> of_irq_put() could be implemented, and it would be a wrapper for
> irq_dispose_mapping()
> 
> as I can see it. Should I do it this way?

Hi Volodymyr

Yes, i think having of_irq_put() would be good. It gives some symmetry
to the API.

   Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
