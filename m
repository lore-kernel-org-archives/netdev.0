From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] ethtool: Display reg dump length via get driver info.
Date: Fri, 18 Mar 2011 21:32:19 +0000
Message-ID: <1300483939.2589.46.camel@bwh-desktop>
References: <ae232d9a-90c7-47ae-856d-bc5a2b3a8037@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46853 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757444Ab1CRVcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 17:32:22 -0400
In-Reply-To: <ae232d9a-90c7-47ae-856d-bc5a2b3a8037@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-18 at 16:06 -0500, Ajit Khaparde wrote:
> Devices like BE store Reg Dump Data in the hardware.

Where else would it be?

> This change will allow to just peek into the hardware
> to see if any data is available for a dump and analysis,
> without actually dumping the register data.
[...]

This is wrong.  ethtool_ops::get_regs_len really should return a
constant, otherwise ethtool (and the kernel) cannot allocate a buffer of
the right size.  If the size of a dump really does vary then make it
return the maximum possible size for the device.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

