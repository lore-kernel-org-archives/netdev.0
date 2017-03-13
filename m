From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: set out of range ageing
 time
Date: Mon, 13 Mar 2017 23:53:02 +0100
Message-ID: <20170313225302.GD14183@lunn.ch>
References: <20170313191932.12149-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Jason Cobham <jcobham@questertangent.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46702 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751687AbdCMWxH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 18:53:07 -0400
Content-Disposition: inline
In-Reply-To: <20170313191932.12149-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 03:19:32PM -0400, Vivien Didelot wrote:
> The minimum and maximum value of the ATU Age Time varies depending on
> the switch model. The current code returns -ERANGE for out-of-range
> values, and makes switchdev commit phase fail with this stacktrace:

Hi Vivien

I took a look at other switch drivers. mlxsw return ERANGE in the
prepare phase. rocker is not limited, since it is using software
timers.

It seems like the correct way to do this is via a prepare call, or add
min/max fields to struct dsa_switch and let slave.c perform the check.

       Andrew
