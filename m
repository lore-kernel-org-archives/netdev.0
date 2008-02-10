From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.24-git] net/enc28j60: low power mode
Date: Sun, 10 Feb 2008 09:45:34 -0800
Message-ID: <200802100945.34287.david-b@pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200802062208.17435.david-b@pacbell.net> <47AAE99D.1000908@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp123.sbc.mail.sp1.yahoo.com ([69.147.64.96]:39166 "HELO
	smtp123.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751963AbYBJRyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 12:54:20 -0500
In-Reply-To: <47AAE99D.1000908@eptar.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 07 February 2008, Claudio Lanconelli wrote:
> Sorry,
> let me repeat what I said in previous mail.
> I propose you to add set_lowpower(true) in the enc28j60_probe() 

As the current patch does...


> and in  the enc28j60_net_close() after enc28j60_hw_disable().
> Probably we don't need to set_lowpower(false) in enc28j60_net_open() since
> it performs a soft reset with enc28j60_hw_init() (not sure).

The current patch sets the device in low power mode in hw_disable(),
and takes it out of that mode in hw_enable().  I can move them; and
the only "soft" thing about this chip's reset is when it starts from
a protocol command not the reset command.


> Furthermore, as you suggested, we also need to remove hw_init() from the 
> setlink()
> because hw_init() is called when we bring link up.
> 
> --- enc28j60.c 20 Dec 2007 10:47:01 -0000 1.22
> +++ enc28j60.c 7 Feb 2008 11:07:20 -0000
> @@ -740,12 +740,6 @@
> if (!priv->hw_enable) {
> if (autoneg == AUTONEG_DISABLE && speed == SPEED_10) {
> priv->full_duplex = (duplex == DUPLEX_FULL);
> - if (!enc28j60_hw_init(priv)) {
> - if (netif_msg_drv(priv))
> - dev_err(&ndev->dev,
> - "hw_reset() failed\n");
> - ret = -EINVAL;
> - }

Right.  Without the patch mangling presumably done by your mailer.  ;)


> } else {
> if (netif_msg_link(priv))
> dev_warn(&ndev->dev,
> 
> Can you update your low power patch with these modifications?
> 

Done -- see my next patch.

