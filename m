From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 07/11] net: dsa: mv88e6xxx: Add mv88e6390 statistics unit init
Date: Mon, 14 Nov 2016 13:29:21 +1100
Message-ID: <87zil2aj5q.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch> <1478832823-31471-8-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41524 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932998AbcKNC31 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 21:29:27 -0500
In-Reply-To: <1478832823-31471-8-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The statistics unit on the mv88e6390 needs to the configured in a
> different register to the others as to what histogram statistics is
> should return.

Can you re-phrase the above please?

> +static int mv88e6390_stats_init(struct mv88e6xxx_chip *chip)
> +{
> +	u16 val;
> +	int err;
> +
> +	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL_2, &val);
> +	if (err)
> +		return err;
> +
> +	val |= GLOBAL_CONTROL_2_HIST_RX_TX;
> +
> +	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL_2, val);
> +
> +	return err;
> +}

Can you please move this Global 1 specific helper in global1.c under an
ordered snippet such as:

    /* Offset 0x1C: Global Control 2 */

    int mv88e6xxx_g1_set_foo(struct mv88e6xxx_chip *chip)
    {
        ...
    }

I'd like internal SMI devices to be self documented in their specific
files and easy to hack for new developers. Ordered helpers will help.

Also, the helper should reflect what it really does. It is used to set
the Histogram Counters Mode. So please name it accordingly, something
like mv88e6xxx_g1_set_hist_count_mode().

Thanks,

        Vivien
