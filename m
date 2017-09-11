From: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] net: ethernet: socionext: add AVE ethernet driver
Date: Mon, 11 Sep 2017 15:51:44 +0900
Message-ID: <20170911155144.6718.4A936039@socionext.com>
References: <1504875731-3680-3-git-send-email-hayashi.kunihiko@socionext.com> <CAK7LNASqfRbG08gvLxx4WxY2Vs2YYPkZ6NUpjj3_OOvOdEBKMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAK7LNASqfRbG08gvLxx4WxY2Vs2YYPkZ6NUpjj3_OOvOdEBKMA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Yamada-san,
Thank you for your comments,

On Fri, 8 Sep 2017 23:44:13 +0900 <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org> wrote:

> 2017-09-08 22:02 GMT+09:00 Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>:
> 
> > diff --git a/drivers/net/ethernet/socionext/Kconfig b/drivers/net/ethernet/socionext/Kconfig
> > new file mode 100644
> > index 0000000..788f26f
> > --- /dev/null
> > +++ b/drivers/net/ethernet/socionext/Kconfig
> > @@ -0,0 +1,22 @@
> > +config NET_VENDOR_SOCIONEXT
> > +       bool "Socionext ethernet drivers"
> > +       default y
> > +       ---help---
> > +         Option to select ethernet drivers for Socionext platforms.
> > +
> > +         Note that the answer to this question doesn't directly affect the
> > +         kernel: saying N will just cause the configurator to skip all
> > +         the questions about Agere devices. If you say Y, you will be asked
> > +         for your specific card in the following questions.
> 
> 
> Agere?

It's wrong. I have template strings left.
I'll fix it.

> > +
> > +       dev_info(dev, "Socionext %c%c%c%c Ethernet IP %s (irq=%d, phy=%s)\n",
> > +                (ave_id >> 24) & 0xff, (ave_id >> 16) & 0xff,
> > +                (ave_id >> 8) & 0xff, (ave_id >> 0) & 0xff,
> > +                buf, ndev->irq, phy_modes(phy_mode));
> > +
> > +       return 0;
> > +err_netdev_register:
> 
> Maybe, a bad label name.
> for ex. out_del_napi or whatever.
> 
> Documentation/process/coding-style.rst says
> "Choose label names which say what the goto does ..."

Yes, I'll rename it according to the document.

> > +       netif_napi_del(&priv->napi_rx);
> > +       netif_napi_del(&priv->napi_tx);
> > +       mdiobus_unregister(priv->mdio);
> > +err_mdiobus_register:
> > +err_mdiobus_alloc:
> > +err_req_irq:
> 
> These three should be merged, for ex.
> out_free_device.

I see. These will be merged.

> I ran sparse for you.
> 
> Please take a look if it is worthwhile.
> Seems endianess around mac_addr.

Okay, I'll check the suspicious code.

> drivers/net/ethernet/socionext/sni_ave.c:423:15: warning: cast to
> restricted __le32
> drivers/net/ethernet/socionext/sni_ave.c:425:20: warning: cast to
> restricted __le16
> drivers/net/ethernet/socionext/sni_ave.c:1194:15: warning: cast to
> restricted __le32
> drivers/net/ethernet/socionext/sni_ave.c:1196:20: warning: cast to
> restricted __le16
> drivers/net/ethernet/socionext/sni_ave.c:1398:15: warning: cast to
> restricted __le32
> drivers/net/ethernet/socionext/sni_ave.c:1400:20: warning: cast to
> restricted __le16
> 
> 
> 
> 
> 
> -- 
> Best Regards
> Masahiro Yamada

---
Best Regards,
Kunihiko Hayashi


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
