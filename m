From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/6] net: dsa: add port_fdb_prepare
Date: Thu, 8 Oct 2015 02:25:43 +0200
Message-ID: <20151008002543.GB31267@lunn.ch>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1444261711-1829-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444261711-1829-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 07, 2015 at 07:48:29PM -0400, Vivien Didelot wrote:
> Push the prepare phase for FDB operations down to the DSA drivers, with
> a new port_fdb_prepare function. Currently only mv88e6xxx is affected.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6171.c |  1 +
>  drivers/net/dsa/mv88e6352.c |  1 +
>  drivers/net/dsa/mv88e6xxx.c | 10 ++++++++++
>  drivers/net/dsa/mv88e6xxx.h |  3 +++
>  include/net/dsa.h           |  4 ++++
>  net/dsa/slave.c             |  7 +++++--
>  6 files changed, 24 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
> index c95cfab..ca3330a 100644
> --- a/drivers/net/dsa/mv88e6171.c
> +++ b/drivers/net/dsa/mv88e6171.c
> @@ -121,6 +121,7 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
>  	.port_vlan_add		= mv88e6xxx_port_vlan_add,
>  	.port_vlan_del		= mv88e6xxx_port_vlan_del,
>  	.vlan_getnext		= mv88e6xxx_vlan_getnext,
> +	.port_fdb_prepare	= mv88e6xxx_port_fdb_prepare,

Hi Vivien

Bike shedding a bit, but i would call this
mv88e6xxx_port_fdb_prepare_add.

>  	.port_fdb_add		= mv88e6xxx_port_fdb_add,
>  	.port_fdb_del		= mv88e6xxx_port_fdb_del,
>  	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,

Taking a theoretical example, say mv88e6xxx_port_fdb_getnext needed a
prepare call to allocate memory to put the returned ATU into. What
would you call that?

mv88e6xxx_port_fdb_prepare_add and mv88e6xxx_port_fdb_prepare_getnext
just seems unambiguous and future proof.

     Andrew
