From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH 1/2] bna: Added flash sub-module and ethtool eeprom
 entry points.
Date: Sat, 24 Dec 2011 11:08:34 +0100
Message-ID: <1324721314.3860.11.camel@deadeye>
References: <1324596585-8614-1-git-send-email-kgudipat@brocade.com>
	 <1324633462.3860.6.camel@deadeye>
	 <B5EE62D80D50B84BB9E5174F7FCCE80A206BE39A24@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@brocade.com>
To: Krishna Gudipati <kgudipat@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17868 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753284Ab1LXKIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2011 05:08:41 -0500
In-Reply-To: <B5EE62D80D50B84BB9E5174F7FCCE80A206BE39A24@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-23 at 07:09 -0800, Krishna Gudipati wrote:
> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Ben Hutchings
> Sent: Friday, December 23, 2011 1:44 AM
> To: Krishna Gudipati
> Cc: davem@davemloft.net; netdev@vger.kernel.org; Adapter Linux Open SRC Team; Rasesh Mody
> Subject: Re: [PATCH 1/2] bna: Added flash sub-module and ethtool eeprom entry points.
> 
> On Thu, 2011-12-22 at 15:29 -0800, kgudipat@brocade.com wrote:
> > From: Krishna Gudipati <kgudipat@brocade.com>
> > 
> > Change details:
> > 	- The patch adds flash sub-module to the bna driver.
> > 	- Added ethtool set_eeprom() and get_eeprom() entry points to
> > 	  support flash partition read/write operations.
> [...]
> 
> I'm not going to say this is wrong, but we didn't find the EEPROM
> operations suitable for firmware upgrade.  I have a couple of questions:
> 
> 1. How long can a single set_eeprom() operation take?
> 2. Have you considered implementing the flash_device() operation or an
> MTD driver?
> 
> -----
> 
> Thanks Ben for reviewing.
> 
> For 1: Considering the max size of the flash image chunk passed to the set_eeprom() entry point
> 	 at a time is 4Kbytes, it takes a little around ~3min for the firmware upgrade as the
> 	 operation involves a flash write for each 4Kbytes of the total 461Kbytes which is our fwimg size.

I asked how long a single call would take, because the RTNL lock will be
held for this time.  Presumably it doesn't take very long to write a 4K
chunk, so this shouldn't be a problem.

> 	 Please note that we use the same entry point to do flash update for other flash partitions as well,
> 	 for which the flash image size is much lesser than the firmware image.
> 
> For 2: No, we noticed that flash_device() entry point is listed as obsolete in the RHEL6.2 kernel source,
> 	 so we did not want to implement using it.

I don't know what makes you think it's obsolete.  It was actually added
recently, so it's not present in RHEL 6.2 (based on Linux 2.6.32).

If you're concerned about how to support this in backports to older
kernel versions, MTD has been around for a very long time and is
available in basically every distribution kernel (but with some
limitations).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
