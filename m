From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Thu, 13 Jul 2006 12:35:37 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093F9C3@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	steve.arden@neterion.com, Dan.Reader@neterion.com,
	leonid.grossman@neterion.com, ananda.raju@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:60678 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030324AbWGMTfs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 15:35:48 -0400
Content-class: urn:content-classes:message
To: ravinandan.arakali@neterion.com,
	"David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ravinandan Arakali wrote:
> But one of the issues is the random/pseudo-random generation of
> ECT code points on each of these segments.

My take is that the ECT code point should also be replicated on
all TSO segments.  When RFC3540 is implemented, the stack will
randomly use ECT(0) or ECT(1) on the TSO super segments.  On
each of these super segments, the hardware will replicate the ECT
code point.  This will keep everything stateless.  The stack
only needs to know the TSO factor (number of divided segements)
for each TSO super segement to keep track of the NS.

