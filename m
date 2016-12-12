From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/3] net:dsa:mv88e6xxx: add helper functions to
 operate on hashtable
Date: Mon, 12 Dec 2016 15:03:49 +0100
Message-ID: <20161212140349.GE27057@lunn.ch>
References: <1481550031-3227-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@westermo.se
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52465 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752357AbcLLODv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 09:03:51 -0500
Content-Disposition: inline
In-Reply-To: <1481550031-3227-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 02:40:31PM +0100, Volodymyr Bendiuga wrote:
> This implementation is similar to rocker driver: drivers/net/ethernet/rocker_ofdpa.c
> 
> mv88e6xxx_pvec_tbl_find - iterates through entries in the hashtable
> and looks for a match.
> 
> mv88e6xxx_pvec_tbl_get - returns en entry if it is found in the
> hashtable
> 
> mv88e6xxx_pvec_tbl_update - updates the hashtable: inserts new entry,
> deletes/modifies existing one.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>

Hi Volodymyr

It looks like your white space is all messed up. Please use checkpatch.

> +
> +static int mv88e6xxx_pvec_tbl_update(struct mv88e6xxx_chip *chip, u16 fid,
> +			      const unsigned char *addr, u16 pvec)
> +{
> +        struct pvec_tbl_entry *obj;
> +        struct pvec_tbl_entry *found;
> +        bool remove = pvec ? false : true;
> +
> +        obj = kzalloc(sizeof(*obj), GFP_KERNEL);
> +        if (!obj)
> +                return -ENOMEM;

So we need to look at the memory model here.

Currently the driver is stateless. This now introduces state. That
means we need to look at the prepare calls switchdev has, since we are
only allowed to fail in the prepare call. You need to allocate the
memory in the port_fdb_prepare() and then use the memory in
port_fdb_add() etc.

I don't think your third patch does any of this.

  Andrew
