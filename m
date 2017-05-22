From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 17/20] net: dsa: add notifier for ageing time
Date: Mon, 22 May 2017 12:38:10 -0700
Message-ID: <3d37b2dd-476a-d339-d730-f14037140177@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-18-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-18-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> This patch keeps the port-wide ageing time handling code in
> dsa_port_ageing_time, pushes the requested ageing time value in a new
> switch fabric notification, and moves the switch-wide ageing time
> handling code in dsa_switch_ageing_time.
> 
> This has the effect that now not only the switch that the target port
> belongs to can be programmed, but all switches composing the switch
> fabric. For the moment, keep the current behavior and ignore other
> switches.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  net/dsa/dsa_priv.h |  8 ++++++++
>  net/dsa/port.c     | 37 ++++++++-----------------------------
>  net/dsa/switch.c   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 62 insertions(+), 29 deletions(-)
> 
> diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
> index c19241eb094b..becaf8a61b13 100644
> --- a/net/dsa/dsa_priv.h
> +++ b/net/dsa/dsa_priv.h
> @@ -17,10 +17,18 @@
>  #include <net/dsa.h>
>  
>  enum {
> +	DSA_NOTIFIER_AGEING_TIME,
>  	DSA_NOTIFIER_BRIDGE_JOIN,
>  	DSA_NOTIFIER_BRIDGE_LEAVE,

This is so we keep sorting notifier events alphabetically, right?
-- 
Florian
