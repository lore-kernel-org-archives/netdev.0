From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 3/4] net: dsa: mv88e6xxx: Move the tagging protocol into info
Date: Fri, 02 Dec 2016 14:41:08 -0500
Message-ID: <87k2bice5n.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch> <1480701779-30633-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52908 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbcLBTlL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 14:41:11 -0500
In-Reply-To: <1480701779-30633-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> @@ -3749,6 +3756,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
>  		.global1_addr = 0x1b,
>  		.age_time_coeff = 15000,
>  		.g1_irqs = 9,
> +		.tag_protocol = DSA_TAG_PROTO_EDSA,
>  		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
>  		.ops = &mv88e6172_ops,
>  	},

Since some chips support several protocols, we will have to turn
tag_protocol into a bitmask and introduce something like:

    enum mv88e6xxx_tag {
        MV88E6XXX_TAG_TRAILER = BIT(DSA_TAG_PROTO_TRAILER),
        MV88E6XXX_TAG_DSA = BIT(DSA_TAG_PROTO_DSA),
        MV88E6XXX_TAG_EDSA = BIT(DSA_TAG_PROTO_EDSA),
    };

But I guess it is OK to force a single one at the moment.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
