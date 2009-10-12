From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [PATCH] [CAIF-RFC 7/8-v2] CAIF Protocol Stack
Date: Mon, 12 Oct 2009 15:43:03 +0200
Message-ID: <4AD33267.2010805@babic.homelinux.org>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-3-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-4-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-5-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-6-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-7-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-8-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout27.attiva.biz ([85.37.16.28]:6701 "EHLO
	smtpout27.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbZJLNnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 09:43:51 -0400
In-Reply-To: <1255095571-6501-8-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 

Hi Sjur,

> +ST-Ericsson modems support a number of transports between modem
> +and host,
> +currently Uart and Shared Memory are available for Linux.

Shared Memory was removed in this patchset.

> +== CAIF structure ==
> +
> +The goal is to have caif as system independent as possible.
> +All caif code can be found under GenCaif/src and GenCaif/inc.

The path are wrong, I think you mean net/caif/generic and include/net/caif.

> +The actual linux module implementation is under src/kernel.
> +There is also a user space program that is not up to date to run the stack in
> +user space for testing.

I think you can remove these phrases.

> +
> +We have tested the kernel implementation on the emulator with a modem and we
> +are able to enumerate and make a link setup.

Only as comment: I tested this patchset again on an ARM platform and I
am able to send successfully AT commands to the Ericsson Test Device "B26".

> +      - CFSHML CAIF Shared Memory layer.

Again, this layer was removed and there is no track about SPI Layer.

> +To achieve this we need the help of a daemon program called ldiscd.
> +The benefit is that we can hook up to any TTY, the downside is that we need
> +an extra operation in order to install the line discipline.

I understand the reason, it looks only a quite odd that we need to start
only for this purpose a user space program. And there is no hint if the
daemon is not started, simply caif does not work. What do you think to
set up the line discipline directly in kernel ?

> +Install the line discipline (daemon)
> +$ ldisc



> +
> +Install the VEI channel (this will enumerate and do the linksetup of the first VEI channel. If this goes well you should see /dev/chn*) (There are printks logging all buffers that can be checked with dmesg):
> +$ modprobe chnl_chr
> +
> +The AT (VEI) channel is ready to use (you can now send AT commands on it):

Not really. at this point, the channels are not configured if we do not
use chardevconfig (or we do the same in kernel).

> diff --git a/Documentation/CAIF/caif_user_config.dox b/Documentation/CAIF/caif_user_config.dox

> +The hardware drivers for the physical links to the modems is configured by \b ACTIVATE or \b DEACTIVATE commands.
> +CAIF PHY Drivers and Channel configuration must be done before any CAIF Channels can be accessed from Linux User Space.
> +
> +\section Defined commands
> +The following commands are defined:
> +- \b CREATE                      - Create a new Net or Character device.
> +- \b DELETE                      - Delete a Net or Character device
> +- \b ACTIVATE                    - Activate a CAIF PHY interface.
> +- \b DEACTIVATE                  - De-activate a CAIF PHY interface.

This file seems obsolete. There is no track about ACTIVATE/DEACTIVATE.

> +
> +\remark
> +Character type devices will show up in /dev/ once they are configured.

If you have udev running on your system....

> +Note also that configured channels are not opened before a file handle is opened from user space.
> +
> +\section Examples
> +The examples below uses the chardevconfig utility as an example on creating channels
> +
> +\subsection Configuration of an AT type Channel:
> +\code
> +$ echo "CREATE TYPE=AT DEV=CHAR NAME=chnlat1" | chrdevconfig /dev/caifconfig

This does not work, PHYPREF is missing.


> +$ echo "CREATE TYPE=RFM DEV=CHAR NAME=rfm01 CONNID=1 VOLUME=/rfm" | chrdevconfig  /dev/caifconfig

This does not work, too

> +$ echo "CONFIG-PHY TYPE=MSL NAME=PHYMSL8 INSTANCE=1 CHECKSUM=no HEAD-ALIGN=2 TAIL-ALIGN=2 TRANSFER-ALIGN=16

...and this one does not work.

> +ACTIVATE				Activates a new CAIF PHY Instance
> +PHYTYPE=[UART|SPI|MSL|SHM|LOOP]	Type of CAIF PHY Instance to configure
> +NAME=<phy-name>			Name of the CAIF PHY Device
> +INSTANCE=<id>				Instance ID of the device
> +CHECKSUM=[yes|no]			Frame Checksum is used for this PHY
> +PARAM=...				Other PHY Specific configuration parameters
> +
> +
> +DEACTIVATE NAME=<phy-name>		De-activates a PHY Instance

Not implemented ?


> diff --git a/Documentation/CAIF/ldiscd/ldiscd.c b/Documentation/CAIF/ldiscd/ldiscd.c
> +#define CAIF_LDISC_TTY	"/dev/ttyS0"

I think it should not be bad to avoid a fixed device name and take it as
program parameter.

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
