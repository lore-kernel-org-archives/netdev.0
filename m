From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 03/14] net: dsa: mv88e6xxx: setup ATU Learn2All
Date: Fri, 10 Mar 2017 03:00:17 +0100
Message-ID: <20170310020017.GG22101@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170309233324.18539-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 09, 2017 at 06:33:13PM -0500, Vivien Didelot wrote:
> Marvell switch chips which can be interconnected have an ATU Learn2All
> feature which allows chosen ports to also learn newly added addresses.
> 
> Enable this feature and mark the DSA links as so called "Message Ports".
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c        | 32 +++++++++++++++++++-------------
>  drivers/net/dsa/mv88e6xxx/global1.h     |  1 +
>  drivers/net/dsa/mv88e6xxx/global1_atu.c | 17 +++++++++++++++++
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  1 +
>  drivers/net/dsa/mv88e6xxx/port.c        | 18 ++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx/port.h        |  2 ++
>  6 files changed, 58 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 0ad8200f3321..132bda7ca9a8 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -1308,6 +1308,14 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
>  
>  static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
>  {
> +	int err;
> +
> +	if (chip->info->tag_protocol != DSA_TAG_PROTO_TRAILER) {

Hi Vivien

I suspect a lot of things are going to go wrong if this driver is ever
used with that tagging protocol. And it will be even worse with QCA or
BRCM. Yes, at some point, 6060 might get merged, and we will have to
scatter such checks around. But until then, please can we not do this.

      Andrew
