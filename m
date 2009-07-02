From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] be2net: Implementation of request_firmware interface.
Date: Thu, 02 Jul 2009 21:33:28 +0100
Message-ID: <1246566808.9821.2.camel@deadeye>
References: <20090702111820.GA21085@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45943 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754016AbZGBUd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 16:33:28 -0400
In-Reply-To: <20090702111820.GA21085@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-02 at 16:48 +0530, Sarveshwar Bandi wrote: 
> Please review and apply patch to net-next tree. Patch implements the 
> request_firmware interface.
[...] 
> +	/* fw ver on board matches */
> +	if (!strncmp(fhdr->sign + strlen(FW_FILE_HDR_SIGN), fw_ver,
> +			FW_VER_LEN))
> +		goto fw_exit;
> +
> +	dev_info(&adapter->pdev->dev,
> +		"Flashing firmware file %s\n", fw_file);
[...]

request_firmware() is really intended for loading non-persistent
"firmware" that must be loaded into the device's RAM after power-on
reset.  It is not expected and should not be necessary that drivers
automatically update firmware in flash memory.  I also understand that
some OEMs specifically forbid their suppliers to do this automatically
in drivers.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
