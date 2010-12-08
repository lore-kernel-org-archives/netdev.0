From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Wed, 8 Dec 2010 20:39:38 +0200
Message-ID: <1291833578.17102.69.camel@lb-tlvb-vladz>
References: <1279832544.2104.63.camel@achroite.uk.solarflarecom.com>
 <4C48BD1A.4060409@chelsio.com>
 <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
 <1291825443.31064.193.camel@lb-tlvb-vladz>
 <1291828940.2560.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Dimitris Michailidis" <dm@chelsio.com>,
	"Peter Waskiewicz" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3793 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753896Ab0LHSjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 13:39:49 -0500
In-Reply-To: <1291828940.2560.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > The
> > semantics for a specification of the steam is also quite different. For
> > instance, how do u define a rule to drop all packets with source IP
> > address 192.168.10.200 by means of RXNFC?
> 
> Something like this, I think:
> 
> struct ethtool_rxnfc insert_rule = {
> 	.cmd = ETHTOOL_SRXCLSRLINS,
> 	.flow_type = IP_USER_SPEC,
> 	.fs = {
> 		.flow_type = IP_USER_SPEC,
> 		.h_u.usr_ip4_spec = {
> 			.ip4src = inet_aton("192.168.10.200"),
> 			.ip_ver = ETH_RX_NFC_IP4
> 		},
> 		.m_u.usr_ip4_spec = {
> 			.ip4dst = 0xffffffff,
> 			.l4_4_bytes = 0xffffffff,
> 			.tos = 0xff,
> 			.proto = 0xff
> 		},
> 		.ring_cookie = RX_CLS_FLOW_DISC,
> 		.location = 0,
> 	}
> };
> 

Aha. Ok. From the remarks in the upstream ethtool.h I see now that
ethtool_rxnfc has quite wide configuration possibilities (including the
above). I missed it before. ;)

Ben, could u, pls., explain me then what's the difference between
defining the rule as u wrote above on top of -N option (nfc) and
defining the rule doing the same thing on top on -U (n-tuple) option and
when I as a user should prefer one option to another? Are they expected
to be implemented differently from FW/HW perspective?

thanks,
vlad

P.S. I see that ethtool.h from the 2.6.36 tree already has the
ethtool_rxnfc that would allow such a filtering definition however from
the man page of the 2.6.36 version of the ethtool package it's unclear
what should be a command line for such a configuration. Is it supported
with the current ethtool version or maybe I'm missing something in a man
page?


