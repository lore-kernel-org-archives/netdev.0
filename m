From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool enhancement proposal
Date: Wed, 18 Apr 2012 17:15:18 +0100
Message-ID: <1334765718.2426.14.camel@bwh-desktop.uk.solarflarecom.com>
References: <A6AA2EF896BED345B0F23520D832A4B10583EC@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stuart Hodgson <smhodgson@solarflare.com>
To: Yaniv Rosner <yaniv.rosner@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23759 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754226Ab2DRQPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 12:15:25 -0400
In-Reply-To: <A6AA2EF896BED345B0F23520D832A4B10583EC@SJEXCHMB05.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 13:05 +0000, Yaniv Rosner wrote:
> Hi Ben,
> I want to propose new enhancement for the ethtool to display the
> content of attached SFP+ module.
> The format should be similar to the "-e" option, and optionally parse
> it's content based on SFF-8472.
> Please let me know what you think.

Stuart Hodgson is working on something like this, though parsing is
unconditional.  I thought he had already posted a patch to netdev, but I
can't see it in the archive.

We discussed the different module formats and came to the conclusion
that:

- Most module types in current use have a 256-byte EEPROM, format
  defined in SFF-8079.
- SFF-8472 specifies two 256-byte EEPROMs/register files, the first
  identical to SFF-8079 and the second carrying diagnostic information.
- The ETHTOOL_GMODULE{EEPROM,INFO} commands should effectively
  concatenate the two.

The current Solarflare controller firmware only provides access to the
SFF-8079 EEPROM on SFP+ modules, so Stuart's code does not cover the
additional diagnostic information.  But that should be easy to add on
top.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
