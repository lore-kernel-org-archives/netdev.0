From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Wed, 08 Dec 2010 19:02:11 +0000
Message-ID: <1291834931.2560.42.camel@bwh-desktop>
References: <1279832544.2104.63.camel@achroite.uk.solarflarecom.com>
	 <4C48BD1A.4060409@chelsio.com>
	 <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
	 <1291825443.31064.193.camel@lb-tlvb-vladz>
	 <1291828940.2560.17.camel@bwh-desktop>
	 <1291833578.17102.69.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:48451 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569Ab0LHTCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 14:02:15 -0500
In-Reply-To: <1291833578.17102.69.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-08 at 20:39 +0200, Vladislav Zolotarov wrote:
> > > The
> > > semantics for a specification of the steam is also quite different. For
> > > instance, how do u define a rule to drop all packets with source IP
> > > address 192.168.10.200 by means of RXNFC?
> > 
> > Something like this, I think:
> > 
> > struct ethtool_rxnfc insert_rule = {
> > 	.cmd = ETHTOOL_SRXCLSRLINS,
> > 	.flow_type = IP_USER_SPEC,
> > 	.fs = {
> > 		.flow_type = IP_USER_SPEC,
> > 		.h_u.usr_ip4_spec = {
> > 			.ip4src = inet_aton("192.168.10.200"),
> > 			.ip_ver = ETH_RX_NFC_IP4
> > 		},
> > 		.m_u.usr_ip4_spec = {
> > 			.ip4dst = 0xffffffff,
> > 			.l4_4_bytes = 0xffffffff,
> > 			.tos = 0xff,
> > 			.proto = 0xff
> > 		},
> > 		.ring_cookie = RX_CLS_FLOW_DISC,
> > 		.location = 0,
> > 	}
> > };
> > 
> 
> Aha. Ok. From the remarks in the upstream ethtool.h I see now that
> ethtool_rxnfc has quite wide configuration possibilities (including the
> above). I missed it before. ;)
> 
> Ben, could u, pls., explain me then what's the difference between
> defining the rule as u wrote above on top of -N option (nfc) and
> defining the rule doing the same thing on top on -U (n-tuple) option and
> when I as a user should prefer one option to another? Are they expected
> to be implemented differently from FW/HW perspective?

The -N option modifies the hash function for all flows of a specific
type (using ETHTOOL_SRXFH) whereas the -U option steers a specific flow
or set of flows (using ETHTOOL_SRXNTUPLE).  The implementation of the -U
option could potentially be made to fallback to ETHTOOL_SRXCLSRLINS if
vlan_tag and user_def are not specified.

> thanks,
> vlad
> 
> P.S. I see that ethtool.h from the 2.6.36 tree already has the
> ethtool_rxnfc that would allow such a filtering definition however from
> the man page of the 2.6.36 version of the ethtool package it's unclear
> what should be a command line for such a configuration. Is it supported
> with the current ethtool version or maybe I'm missing something in a man
> page?

It's not supported.  Santwona Behera implemented the kernel side of this
but so far as I know he never sent any patches for ethtool.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

