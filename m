From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Sun, 02 May 2010 12:50:56 +0200
Message-ID: <4BDD5910.1040604@grandegger.com>
References: <20100429091936.GA6703@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:45384 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280Ab0EBKwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 06:52:50 -0400
In-Reply-To: <20100429091936.GA6703@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

Richard Cochran wrote:
> This patch adds an infrastructure for hardware clocks that implement
> IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
> registration method to particular hardware clock drivers. Each clock is
> exposed to user space as a character device with ioctls that allow tuning
> of the PTP clock.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
...
> diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
> new file mode 100644
> index 0000000..a5acac4
> --- /dev/null
> +++ b/drivers/ptp/ptp_clock.c
...
> +static int ptp_open(struct inode *inode, struct file *fp)
> +{
> +	struct ptp_clock *ptp;
> +	ptp = container_of(inode->i_cdev, struct ptp_clock, cdev);
> +
> +	if (mutex_lock_interruptible(&ptp->mux))
> +		return -ERESTARTSYS;
> +
> +	fp->private_data = ptp;
> +
> +	return 0;
> +}
...
> +static int ptp_release(struct inode *inode, struct file *fp)
> +{
> +	struct ptp_clock *ptp = fp->private_data;
> +	mutex_unlock(&ptp->mux);
> +	return 0;
> +}

As long as the device is in use by an application, no other can access
it, because the mutex is locked. Other application may want to read the
PTP clock time while ptpd is running, though.

Wolfgang.
