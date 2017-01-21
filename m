From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/8] net: dsa: mv88e6xxx: Set the CMODE for mv88e6390 ports 9 & 10
Date: Fri, 20 Jan 2017 19:20:10 -0500
Message-ID: <8737gdfemd.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch> <1484955062-26718-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57676 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752276AbdAUAUj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:20:39 -0500
In-Reply-To: <1484955062-26718-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Unlike most ports, ports 9 and 10 of the 6390X family have configurable
> PHY modes. Set the mode as part of adjust_link().
>
> Ordering is important, because the SERDES interfaces connected to
> ports 9 and 10 can be split and assigned to other ports. The CMODE has
> to be correctly set before the SERDES interface on another port can be
> configured. Such configuration is likely to be performed in
> port_enable() and port_disabled(), called on slave_open() and
> slave_close().
>
> The simple case is port 9 and 10 are used for 'CPU' or 'DSA'. In this
> case, the CMODE is set via a phy-mode in dsa_cpu_dsa_setup(), which is
> called early in the switch setup.
>
> When ports 9 or 10 are used as user ports, and have a fixed-phy, when
> the fixed fixed-phy is attached, dsa_slave_adjust_link() is called,
> which results in the adjust_link function being called, setting the
> cmode. The port_enable() will for other ports will be called much
> later.
>
> When ports 9 or 10 are used as user ports and have a real phy attached
> which does not use all the available SERDES interface, e.g. a 1Gbps
> SGMII, there is currently no mechanism in place to set the CMODE of
> the port from software. It must be hoped the stripping resistors are
> correct.
>
> At the same time, add a function to get the cmode. This will be needed
> when configuring the SERDES interfaces.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks for the very descriptive message, the patch looks perfect.

        Vivien
