From: Zoltan Farkas <zfarkas@lutra.sztaki.hu>
Subject: Re: [RFC] multiple eth0 mixed PCI/ISA init
Date: Sat, 20 Dec 2003 12:33:34 +0100 (MET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GS4.4.33.0312201232460.28011-100000@lutra.sztaki.hu>
References: <20031219151415.1cfdbe66.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, Alexander Viro <aviro@redhat.com>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031219151415.1cfdbe66.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Dec 2003, Stephen Hemminger wrote:

> PCI is getting initialized before the old ISA probing code, so your PCI card
> is grabbing eth0 before the ISA card gets started.
>
> You might be able workaround the problem probably by doing:
> 	netdev=0,1,0,0,eth0
> which should cause the ISA probe code to skip eth0 and go on to eth1
>
> This patch should fix 2.6.0 (have similar but different fix for net-drivers-2.5-exp).
> I don't have an ISA card to actually test this code path.
>
> diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
> --- a/drivers/net/Space.c	Fri Dec 19 15:10:50 2003
> +++ b/drivers/net/Space.c	Fri Dec 19 15:10:50 2003
> @@ -350,7 +350,7 @@
>  	 * Backwards compatibility - historically an I/O base of 1 was
>  	 * used to indicate not to probe for this ethN interface
>  	 */
> -	if (dev->base_addr == 1) {
> +	if (__dev_get_by_name(dev->name) || dev->base_addr == 1) {
>  		free_netdev(dev);
>  		return -ENXIO;
>  	}
>
Thanks a lot! This has fixed my problem. Now my ISA card initializes as
eth1.
Cheers,

	Zoltan
