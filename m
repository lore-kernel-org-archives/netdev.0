From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [RFC PATCH 1/3] net: dsa: Use devm_ prefixed allocations
Date: Wed, 30 Sep 2015 18:34:29 -0300
Message-ID: <CAOMZO5A6UyLN2w3jsQB4r48-jOfKep6abkW0p+-Emsg0-hvkRw@mail.gmail.com>
References: <560B9B74.3080905@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Lunn <andrew@lunn.ch>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560B9B74.3080905@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 5:21 AM, Neil Armstrong <narmstrong@baylibre.com> wrote:
> To simplify and prevent memory leakage when unbinding, use
> the devm_ memory allocation calls.
>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  net/dsa/dsa.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index c59fa5d..98f94c2 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -305,7 +305,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>         if (ret < 0)
>                 goto out;
>
> -       ds->slave_mii_bus = mdiobus_alloc();
> +       ds->slave_mii_bus = devm_mdiobus_alloc(parent);
>         if (ds->slave_mii_bus == NULL) {
>                 ret = -ENOMEM;
>                 goto out;
> @@ -400,7 +400,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>         /*
>          * Allocate and initialise switch state.
>          */
> -       ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
> +       ds = devm_kzalloc(parent, sizeof(*ds) + drv->priv_size, GFP_KERNEL);

Shouldn't devm_ functions be called only from probe and remove functions?
