From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: 2.6.12-rc1-mm1: hostap stack usage
Date: Tue, 22 Mar 2005 20:59:10 -0800
Message-ID: <20050323045909.GT8648@jm.kir.nu>
References: <20050321025159.1cabd62e.akpm@osdl.org>
	<20050322163340.GD1948@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
	hostap@shmoo.com, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, jgarzik@pobox.com
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050322163340.GD1948@stusta.de>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://incognito.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

(netdev added to cc:)

On Tue, Mar 22, 2005 at 05:33:40PM +0100, Adrian Bunk wrote:

> The stack usage in some files under drivers/net/wireless/hostap/ is
> too high.

Thanks; I'll fix these and submit a patch (or two) after some testing.

> drivers/net/wireless/hostap/hostap_ioctl.c:
> 
> prism2_ioctl_giwaplist:
>         struct sockaddr addr[IW_MAX_AP];
>         struct iw_quality qual[IW_MAX_AP];
> 
> 64 * (16 + 4) Bytes = 1280 Bytes

OK.

> prism2_ioctl_ethtool:
>         struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
> 
> 196 Bytes

This seems to be somewhat obsolete now since most drivers have moved to
use get_drvinfo of ethtool_ops; I'll do the same.

> __prism2_translate_scan:
>         char buf[MAX_WPA_IE_LEN * 2 + 30];
> 
> (64 * 2) + 30 Bytes = 158 Bytes

OK.

> drivers/net/wireless/hostap/hostap_cs.c:
> 
> prism2_config:
>         cisparse_t parse;
>         u_char buf[64];
>         config_info_t conf;
> 
> The main offender seems to be "parse" (but I'm too lame counting how 
> many bytes it's exactly) resulting in nearly 1 kB stack usage.

This is actually very common for PC Card drivers in the current kernel
tree.. I'll change Host AP to kmalloc this, but someone might consider
going through all *_cs.c drivers..

> drivers/net/wireless/hostap/hostap_plx.c:
> 
> prism2_plx_check_cis:
> #define CIS_MAX_LEN 256
>         u8 cis[CIS_MAX_LEN];

OK.

-- 
Jouni Malinen                                            PGP id EFC895FA
