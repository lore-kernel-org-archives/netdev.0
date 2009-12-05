From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 11/31] Constify struct file_operations for 2.6.32 v1
Date: Fri, 4 Dec 2009 16:09:42 -0800
Message-ID: <20091205000942.GA8224@suse.de>
References: <4B198670.2000406@gmail.com>
 <4B198C43.50205@gmail.com>
 <4B19A333.5080103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lenb@kernel.org, astarikovskiy@suse.de, mchehab@infradead.org,
	linville@tuxdriver.com, miklos@szeredi.hu, davem@davemloft.net,
	rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com,
	avi@redhat.com, mtosatti@redhat.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Emese Revfy <re.emese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:43237 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932581AbZLEAK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 19:10:57 -0500
Content-Disposition: inline
In-Reply-To: <4B19A333.5080103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 05, 2009 at 01:02:59AM +0100, Emese Revfy wrote:
> From: Emese Revfy <re.emese@gmail.com>
> 
> Constify struct file_operations with some exceptions.
> Per Dave Miller's suggestion, resend with proper CC list and patch format.
> 
> Signed-off-by: Emese Revfy <re.emese@gmail.com>
> ---
>  drivers/acpi/battery.c                           |    2 +-
>  drivers/char/pty.c                               |   16 +++++++++---
>  drivers/char/tty_io.c                            |   28 ++++-----------------
>  drivers/media/dvb/dvb-core/dvbdev.c              |    1 +
>  drivers/net/wireless/b43/debugfs.c               |    2 +-
>  drivers/net/wireless/b43legacy/debugfs.c         |    2 +-
>  drivers/net/wireless/libertas/debugfs.c          |    2 +-
>  drivers/staging/b3dfg/b3dfg.c                    |    2 +-
>  drivers/staging/dream/qdsp5/adsp_driver.c        |    2 +-
>  drivers/staging/dream/qdsp5/audio_aac.c          |    2 +-
>  drivers/staging/dream/qdsp5/audio_amrnb.c        |    2 +-
>  drivers/staging/dream/qdsp5/audio_evrc.c         |    2 +-
>  drivers/staging/dream/qdsp5/audio_in.c           |    4 +-
>  drivers/staging/dream/qdsp5/audio_mp3.c          |    2 +-
>  drivers/staging/dream/qdsp5/audio_out.c          |    4 +-
>  drivers/staging/dream/qdsp5/audio_qcelp.c        |    2 +-
>  drivers/staging/dream/qdsp5/snd.c                |    2 +-
>  drivers/staging/dream/smd/smd_qmi.c              |    2 +-
>  drivers/staging/dream/smd/smd_rpcrouter_device.c |    4 +-
>  drivers/staging/panel/panel.c                    |    4 +-
>  drivers/staging/poch/poch.c                      |    2 +-
>  drivers/staging/sep/sep_driver.c                 |    2 +-
>  drivers/staging/vme/devices/vme_user.c           |    2 +-
>  fs/fuse/cuse.c                                   |   20 +++++++++------
>  fs/fuse/dev.c                                    |    8 +++---
>  fs/fuse/fuse_i.h                                 |   10 ++++++++
>  include/linux/tty.h                              |   14 ++++++++++-
>  include/net/tcp.h                                |    1 +
>  include/net/udp.h                                |    1 +
>  kernel/trace/trace_events.c                      |    2 +
>  virt/kvm/kvm_main.c                              |    3 ++
>  31 files changed, 89 insertions(+), 63 deletions(-)
> 
> diff --git a/drivers/acpi/battery.c b/drivers/acpi/battery.c
> index 3f4602b..2e41d36 100644
> --- a/drivers/acpi/battery.c
> +++ b/drivers/acpi/battery.c
> @@ -763,7 +763,7 @@ DECLARE_FILE_FUNCTIONS(alarm);
>  	}
>  
>  static struct battery_file {
> -	struct file_operations ops;
> +	const struct file_operations ops;
>  	mode_t mode;
>  	const char *name;
>  } acpi_battery_file[] = {
> diff --git a/drivers/char/pty.c b/drivers/char/pty.c
> index 62f282e..d39c67b 100644
> --- a/drivers/char/pty.c
> +++ b/drivers/char/pty.c
> @@ -682,7 +682,18 @@ static int ptmx_open(struct inode *inode, struct file *filp)
>  	return ret;
>  }
>  
> -static struct file_operations ptmx_fops;
> +static const struct file_operations ptmx_fops = {
> +	.llseek		= no_llseek,
> +	.read		= tty_read,
> +	.write		= tty_write,
> +	.poll		= tty_poll,
> +	.unlocked_ioctl	= tty_ioctl,
> +	.compat_ioctl	= tty_compat_ioctl,
> +	.open		= ptmx_open,
> +	.release	= tty_release,
> +	.fasync		= tty_fasync,
> +};

You just made these functions all global, for no real good reason.  Why
did you do this?

confused,

greg k-h
