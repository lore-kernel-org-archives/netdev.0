From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: Re: [PATCH] be2net: Implementation of request_firmware interface.
Date: Sun, 5 Jul 2009 17:46:38 +0530
Message-ID: <20090705121637.GA3627@serverengines.com>
References: <20090702111820.GA21085@serverengines.com> <1246566808.9821.2.camel@deadeye>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:49207 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753168AbZGEMQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 08:16:35 -0400
Content-Disposition: inline
In-Reply-To: <1246566808.9821.2.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I understand that most drivers  use request_firmware() to load  volatile
firmware. I do see that there are other nic drivers that use this inferface to
flash persistent firmware.

 We have other tools for offline flashing; but there is requirement
to flash f/w through driver without having to use other proprietary  tools.
Since the firmware load happens only when there is a version mismatch with
f/w in /lib/firmware, Users who want to avoid automatic flashing at boot time
can choose not to copy the f/w file under /lib/firmware.

- Sarvesh

On 02/07/09 21:33 +0100, Ben Hutchings wrote:
> On Thu, 2009-07-02 at 16:48 +0530, Sarveshwar Bandi wrote: 
> > Please review and apply patch to net-next tree. Patch implements the 
> > request_firmware interface.
> [...] 
> > +	/* fw ver on board matches */
> > +	if (!strncmp(fhdr->sign + strlen(FW_FILE_HDR_SIGN), fw_ver,
> > +			FW_VER_LEN))
> > +		goto fw_exit;
> > +
> > +	dev_info(&adapter->pdev->dev,
> > +		"Flashing firmware file %s\n", fw_file);
> [...]
> 
> request_firmware() is really intended for loading non-persistent
> "firmware" that must be loaded into the device's RAM after power-on
> reset.  It is not expected and should not be necessary that drivers
> automatically update firmware in flash memory.  I also understand that
> some OEMs specifically forbid their suppliers to do this automatically
> in drivers.
> 
> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
