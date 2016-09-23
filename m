From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: dsa: add port fast ageing
Date: Thu, 22 Sep 2016 22:36:01 -0700
Message-ID: <3d45f509-371e-85f3-3ab2-fcb783ebb371@gmail.com>
References: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09/22/2016 01:49 PM, Vivien Didelot wrote:
> Today the DSA drivers are in charge of flushing the MAC addresses
> associated to a port when its STP state changes from Learning or
> Forwarding, to Disabled or Blocking or Listening.
> 
> This makes the drivers more complex and hides this generic switch logic.
> 
> This patchset introduces a new optional port_fast_age operation to
> dsa_switch_ops, to move this logic to the DSA layer and keep drivers
> simple. b53 and mv88e6xxx are updated accordingly.

This looks good, just one minor thing, both the b53 and mv88e6xxx can
actually return an error from fast ageing a port, should we account for
that? Not that we would be doing something about it though...

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Vivien Didelot (4):
>   net: dsa: add port STP state helper
>   net: dsa: add port fast ageing
>   net: dsa: b53: implement DSA port fast ageing
>   net: dsa: mv88e6xxx: implement DSA port fast ageing
> 
>  drivers/net/dsa/b53/b53_common.c | 31 ++++++++++-----------------
>  drivers/net/dsa/mv88e6xxx/chip.c | 45 ++++++++++++++++++++--------------------
>  include/net/dsa.h                |  2 ++
>  net/dsa/slave.c                  | 35 ++++++++++++++++++++++++-------
>  4 files changed, 64 insertions(+), 49 deletions(-)
> 
