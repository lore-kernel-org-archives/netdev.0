From: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
Subject: Re: [PATCH 0/7] mv643xx_eth: device tree bindings
Date: Mon, 6 May 2013 12:07:43 -0400
Message-ID: <20130506160743.GV31290@titan.lakedaemon.net>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Nigel Roberts <nigel-BZPLJ9//LnDby3iVrkZq2A@public.gmane.org>, Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>,
 Valentin Longchamp <valentin.longchamp-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>,
 Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
 Simon Guinot <simon.guinot-jKBdWWKqtFpg9hUCZPvPmw@public.gmane.org>,
 Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 Eric Hutter <hutter.eric-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>, Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
 Joshua Coombs <josh.coombs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan M Butler <alanbutty12-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Willy Tarreau <w@1wt.eu>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Stefan Peter <s.peter-R0yVo0h44Ow@public.gmane.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367854420-8006-1-git-send-email-sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Sebastian,

Thanks for picking this up!  A few comments about merging strategy:

On Mon, May 06, 2013 at 05:33:33PM +0200, Sebastian Hesselbarth wrote:
> This patch set picks up work by Florian Fainelli bringing full DT
> support to mv643xx_eth and Marvell SoCs using it.
> 
> The current patch set drops Florian's device tree conversions for
> Kirkwood, Dove, and Orion5x in favour of split patches for board
> files and board descriptor files.
> 
> Device tree conversion for Dove and Kirkwood is added. Dove has
> been fully tested, while Kirkwood is compile-tested only.
> 
> Florian Fainelli (2):
>   net: mv643xx_eth: add Device Tree bindings
>   net: mv643xx_eth: update Device Tree bindings documentation

Obviously, these will go through -net once the submission window opens.

> Sebastian Hesselbarth (5):
(reordered for clarity)

>   ARM: dove: remove legacy mv643xx_eth setup
>   ARM: kirkwood: remove legacy mv643xx_eth board setup
>   ARM: kirkwood: remove legacy clk alias for mv643xx_eth

mvebu/boards or /soc.

>   ARM: kirkwood: add gigabit ethernet and mvmdio device tree nodes
>   ARM: dove: add gigabit ethernet and mvmdio device tree nodes

mvebu/dt


mvebu/dt and -net are fine.  They have no dependencies.  The problem is
mvebu/boards.  To boot with networking, it needs -net *and* mvebu/dt.
Otherwise, the board needs to do legacy init.

I'd like to attempt to remove this dependency-hell with code.  eg some
quick pseudo-code:

	if (!dt_node_present("marvell,mv643xx_eth") ||
	    !mvebu_dt_bindings_present())
		kirkwood_ge00_init();

The advantages of figuring this out are:
 - *no* branch dependencies
 - whole conversion done in one merge window

The drawbacks:
 - need to remember to do a follow-on patch if all branches are
   successfuly merged, removing the unneeded logic (after -rc1)
 - considered churn?

The easy answer is to merge mvebu/dt, and -net, wait one cycle, and
merge the board stuff as you have it now (with Thomas' comment).

If we can figure this out, I'd like to do the same for the kirkwood-pcie
series.

thoughts?

thx,

Jason.
