From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 10/11] net: dsa: mv88e6xxx: remove EEE support
Date: Tue, 1 Aug 2017 16:28:43 +0200
Message-ID: <20170801142843.GE23157@lunn.ch>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
 <20170731221719.16695-11-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170731221719.16695-11-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2017 at 06:17:18PM -0400, Vivien Didelot wrote:
> The PHY's EEE settings are already accessed by the DSA layer through the
> Marvell PHY driver and there is nothing to be done for switch's MACs.

I'm confused, or missing something. Does not patch #1 mean that if the
DSA driver does not have a set_eee function, we always return -ENODEV
in slave.c?

There might be nothing to configure here, but some of the switches do
support EEE. So we need at least a NOP set_eee. Better still it should
return -ENODEV for those switches which don't actually support EEE,
and 0 for those that do?

    Andrew
