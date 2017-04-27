From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 08/18] net: dsa: mv88e6xxx: move generic VTU
 GetNext
Date: Thu, 27 Apr 2017 20:59:12 +0200
Message-ID: <20170427185912.GK17364@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43706 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753901AbdD0S7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 14:59:16 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-9-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:26AM -0400, Vivien Didelot wrote:
> Even though every switch model has a different way to access the VTU
> Data bits, the base implementation of the VTU GetNext operation remains
> the same: wait, write the first VID to iterate from, start the
> operation, and read the next VID.
> 
> Move this generic implementation into global_vtu.c and abstract the

global1_vtu.c

> +int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
> +			     struct mv88e6xxx_vtu_entry *entry)
> +{
> +	int err;
> +
> +	err = mv88e6xxx_g1_vtu_op_wait(chip);
> +	if (err)
> +		return err;
> +
> +	/* Write the VID to iterate from only once */
> +	if (!entry->valid) {
> +		err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
> +		if (err)
> +			return err;
> +	}

Please could you add a bigger comment. It is not clear why you write
it, when it is invalid. That just seems wrong, and needs a good
comment to explain why it is correct, more than what you currently
have as a comment.

Thanks
	Andrew
