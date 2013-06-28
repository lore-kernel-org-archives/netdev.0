From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Add Kconfig dependency on
	GRE-DEMUX.
Date: Fri, 28 Jun 2013 19:54:52 +0100
Message-ID: <1372445692.1937.27.camel@bwh-desktop.uk.level5networks.com>
References: <1372444222-29379-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1372444222-29379-1-git-send-email-pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-28 at 11:30 -0700, Pravin B Shelar wrote:
> Openvswitch uses function from NET_IPGRE_DEMUX module.
> Add Kconfig dependency to fix compilation errors.

That's not an obvious dependency, and this may result in OPENVSWITCH
being inexplicably disabled when people update their custom kernel
configs.

Either OPENVSWITCH should select NET_IPGRE_DEMUX, or the code should be
fixed to work without it.  I don't know what the breakage was but I
would guess that you could use an automatic config symbol like:

bool OPENVSWITCH_IPGRE_SUPPORT
	depends on OPENVSWITCH && NET_IPGRE_DEMUX && !(OPENVSWITCH=y && NET_IPGRE_DEMUX=m)

Ben.

> CC: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Reported-by: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Signed-off-by: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> ---
>  net/openvswitch/Kconfig     |    1 +
>  net/openvswitch/vport-gre.c |    2 --
>  net/openvswitch/vport.c     |    3 ---
>  3 files changed, 1 insertions(+), 5 deletions(-)
> 
> diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
> index 9fbc04a..9fc0df2 100644
> --- a/net/openvswitch/Kconfig
> +++ b/net/openvswitch/Kconfig
> @@ -4,6 +4,7 @@
>  
>  config OPENVSWITCH
>  	tristate "Open vSwitch"
> +	depends on NET_IPGRE_DEMUX
>  	---help---
>  	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
>  	  environments.  In addition to supporting a variety of features
> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
> index 943e5c4..21d5073 100644
> --- a/net/openvswitch/vport-gre.c
> +++ b/net/openvswitch/vport-gre.c
> @@ -16,7 +16,6 @@
>   * 02110-1301, USA
>   */
>  
> -#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
>  #include <linux/if.h>
> @@ -271,4 +270,3 @@ const struct vport_ops ovs_gre_vport_ops = {
>  	.get_name	= gre_get_name,
>  	.send		= gre_tnl_send,
>  };
> -#endif
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index ba81294..ba240a8 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -38,10 +38,7 @@
>  static const struct vport_ops *vport_ops_list[] = {
>  	&ovs_netdev_vport_ops,
>  	&ovs_internal_vport_ops,
> -
> -#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
>  	&ovs_gre_vport_ops,
> -#endif
>  };
>  
>  /* Protected by RCU read lock for reading, ovs_mutex for writing. */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
