From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 08/11] net: dsa: mv88e6xxx: Add stats_get_sset_count to ops structure
Date: Mon, 14 Nov 2016 13:47:39 +1100
Message-ID: <87wpg6aib8.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch> <1478832823-31471-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:42428 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754520AbcKNCrq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 21:47:46 -0500
In-Reply-To: <1478832823-31471-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Different families have different sets of statistics. Abstract this
> using a stats_get_sset_count op. Each stat has a bitmap, and the ops
> implementer uses a bit map mask to count the statistics which apply
> for the family.

> -static int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
> +static int _mv88e6xxx_get_sset_count(struct mv88e6xxx_chip *chip, int types)

Looks good overall. But please don't re-introduce underscore-prefixed
helpers. If I'm not mistaken, stats are a Global 1 feature, so ordered
explicit helpers in global1.c will be perfect.

If the stats code is huge, don't hesitate to move them in a
global1_stats.c file, as you wish. But we have to keep it
self-documented and easy to follow for new developers.

Thanks,

        Vivien
