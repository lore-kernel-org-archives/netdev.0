From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [RFC] [PATCH 1/7] pcmcia: add pcmcia_loop_config() helper
Date: Tue, 29 Jul 2008 14:16:42 -0700
Message-ID: <20080729141642.47c8d6ca.rdunlap@xenotime.net>
References: <20080729071539.GB27385@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia@lists.infradead.org, Tejun Heo <htejun@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-ide@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	linux-bluetooth@vger.kernel.org,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	linux-scsi@vger.kernel.org, Karsten Keil <kkeil@suse.de>,
	isdn4linux@listserv.isdn4linux.de, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
	linux-parport@lists.infradead.org,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Ed Okerson <eokerson@quicknet.net>,
	linux-serial@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <20080729071539.GB27385@comet.dominikbrodowski.net>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Jul 2008 09:15:39 +0200 Dominik Brodowski wrote:

> By calling pcmcia_loop_config(), a pcmcia driver can iterate over all
> available configuration options. During a driver's probe() phase, one
> doesn't need to use pcmcia_get_{first,next}_tuple, pcmcia_get_tuple_data
> and pcmcia_parse_tuple directly in most if not all cases.
> 
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  Documentation/pcmcia/driver-changes.txt |    6 +++
>  drivers/pcmcia/pcmcia_resource.c        |   57 +++++++++++++++++++++++++++++++
>  include/pcmcia/cistpl.h                 |    6 +++
>  3 files changed, 69 insertions(+), 0 deletions(-)
> 
> By calling pcmcia_loop_config(), a pcmcia driver can iterate over all
> available configuration options. During a driver's probe() phase, one
> doesn't need to use pcmcia_get_{first,next}_tuple, pcmcia_get_tuple_data
> and pcmcia_parse_tuple directly in most if not all cases.
> 
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  Documentation/pcmcia/driver-changes.txt |    6 +++
>  drivers/pcmcia/pcmcia_resource.c        |   63 +++++++++++++++++++++++++++++++
>  include/pcmcia/cistpl.h                 |    6 +++
>  3 files changed, 75 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
> index 4884a18..0fa48aa 100644
> --- a/drivers/pcmcia/pcmcia_resource.c
> +++ b/drivers/pcmcia/pcmcia_resource.c
> @@ -909,3 +909,66 @@ void pcmcia_disable_device(struct pcmcia_device *p_dev) {
>  		pcmcia_release_window(p_dev->win);
>  }
>  EXPORT_SYMBOL(pcmcia_disable_device);
> +
> +

Hi,

One more comment here (sorry I missed it earlier):

The kernel-doc comment needs to immediately precede the function, so that
struct pcmcia_cfg_mem needs to be moved to before the kernel-doc block...


> +/**
> + * pcmcia_loop_config() - loop over configuration options
> + * @p_dev:	the struct pcmcia_device which we need to loop for.
> + * @conf_check:	function to call for each configuration option.
> + *		It gets passed the struct pcmcia_device, the CIS data
> + *		describing the configuration option, and private data
> + *		being passed to pcmcia_loop_config()
> + * @priv_data:	private data to be passed to the conf_check function.
> + *
> + * pcmcia_loop_config() loops over all configuration options, and calls
> + * the driver-specific conf_check() for each one, checking whether
> + * it is a valid one.
> + */
> +
> +struct pcmcia_cfg_mem {
> +	tuple_t tuple;
> +	cisparse_t parse;
> +	u8 buf[256];
> +};
> +
> +int pcmcia_loop_config(struct pcmcia_device *p_dev,
> +		       int	(*conf_check)	(struct pcmcia_device *p_dev,
> +						 cistpl_cftable_entry_t *cfg,
> +						 void *priv_data),
> +		       void *priv_data)
> +{
...
> +}
> +EXPORT_SYMBOL(pcmcia_loop_config);


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
