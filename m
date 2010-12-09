From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Thu, 9 Dec 2010 12:31:27 +0200
Message-ID: <1291890687.24019.29.camel@lb-tlvb-vladz>
References: <4C48BD1A.4060409@chelsio.com>
 <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
 <1291825443.31064.193.camel@lb-tlvb-vladz>
 <20101208.083921.71108761.davem@davemloft.net>
 <1291829364.2560.24.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"dm@chelsio.com" <dm@chelsio.com>,
	"peter.p.waskiewicz.jr@intel.com" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4867 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755932Ab0LIKbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 05:31:40 -0500
In-Reply-To: <1291829364.2560.24.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > It's not the same, this whole ordering thing you expect in netfilter
> > land is simply not present in these hardware implementations.
> > 
> > The hardware does a parallel TCAM match lookup, and whatever matches
> > is used.
> 
> I think the match with the lowest index wins, which is why it's possible
> to specify the rule's index (location) with ETHTOOL_SRXCLSRLINS and why
> Peter defined new commands without that for use with the ixgbe driver.
> 

Ben, practically, with the current ethtool userspace implementation it
seems like there is no way to specify the CAM index of the rule in the
n-tuple interface, is it? So, the decision on the index is up to the
vendor thus creating an uncertainty space. 

And I guess it's exactly what Dimitris meant talking about the index -
he said "a rule index", u say "a CAM index" while generally we are
talking about the same thing. U r referring the ETHTOOL_SRXCLSRLINS but
it has no user space interface yet and it's unclear when it will, while
n-tuple is already there. We can't remove the existing user space
interfaces - I agree. Then let's not adding the interfaces interfering
with the existing ones. This immediately implies that
ETHTOOL_SRXCLSRLINS shell never see light in a userland as a separate
interface and n-tuple user interface should be properly extended to
implement the missing ETHTOOL_SRXCLSRLINS functionality.

Pls., comment.

thanks,
vlad


