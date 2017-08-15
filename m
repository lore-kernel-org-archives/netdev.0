From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] of_mdio: merge branch tails in
 of_phy_register_fixed_link()
Date: Tue, 15 Aug 2017 11:18:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0055AAA@AcuExch.aculab.com>
References: <20170812210321.520045884@cogentembedded.com>
 <20170813.200908.1426365653542179792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "andrew-g2DYL2Zd6BY@public.gmane.org" <andrew-g2DYL2Zd6BY@public.gmane.org>,
        "f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org"
        <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170813.200908.1426365653542179792.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller
> Sent: 14 August 2017 04:09
> From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
> Date: Sun, 13 Aug 2017 00:03:06 +0300
> 
> > Looks  like gcc isn't always able to figure  out that 3 *if* branches in
> > of_phy_register_fixed_link() calling fixed_phy_register() at their ends
> > are similar enough and thus can be merged. The "manual" merge saves 40
> > bytes of the object code (AArch64 gcc 4.8.5), and still saves 12 bytes
> > even  if gcc was able to merge the branch tails (ARM gcc 4.8.5)...
> >
> > Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
> 
> Applied, but if two instances of the "same" compiler just with
> different targets changes the optimization, it could be because of a
> tradeoff which is specific to parameters expressed in that target's
> backend.
> 
> So in the future we should probably back away from trying to "help"
> the compiler in this way.

Probably a trade off between code size and execution speed.
I've had 'fun' trying to stop gcc merging tail code paths
in order to avoid the cost of the branch instruction.

	David

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
