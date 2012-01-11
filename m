From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: bridge: netfilter: Fix dependency for
 BRIDGE_NF_EBTABLES
Date: Tue, 10 Jan 2012 17:52:51 -0800
Message-ID: <20120110175251.4b6ad831@nehalam.linuxnetplumber.net>
References: <1326246505-5038-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <fabio.estevam@freescale.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: Fabio Estevam <festevam@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1326246505-5038-1-git-send-email-festevam@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Jan 2012 23:48:25 -0200
Fabio Estevam <festevam@gmail.com> wrote:

> Fix the following build warning:
> 
> warning: (BRIDGE_NF_EBTABLES) selects NETFILTER_XTABLES which has unmet direct dependencies (NET && INET && NETFILTER)
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
>  net/bridge/netfilter/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
> index a9aff9c..9ca621a 100644
> --- a/net/bridge/netfilter/Kconfig
> +++ b/net/bridge/netfilter/Kconfig
> @@ -4,7 +4,7 @@
>  
>  menuconfig BRIDGE_NF_EBTABLES
>  	tristate "Ethernet Bridge tables (ebtables) support"
> -	depends on BRIDGE && NETFILTER
> +	depends on BRIDGE && NETFILTER && INET
>  	select NETFILTER_XTABLES
>  	help
>  	  ebtables is a general, extensible frame/packet identification

Almost everybody has INET defined... but still it should be possible to run ebtables
without INET layer. Looks like a but in XTABLES to me.
