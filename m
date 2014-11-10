From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: question about ethtool bits?
Date: Mon, 10 Nov 2014 12:47:18 -0800
Message-ID: <20141110124718.00004efc@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63473 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbaKJUrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2014 15:47:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben et al,

So, I was just looking at adding some more types/speeds to
ethtool.h and noticed we are about out of bits in ecmd->advertising
(and others), which are declared u32.

We currently have room for one more type (bit 31) and then all 32 bits
will be full.

Previous solutions have involved adding a new struct member to the end
of ecmd and friends and calling it u32 advertising2 or something.
Another option could be adding a u64, but there may be not fun results
of doing so.

...
#define SUPPORTED_56000baseSR4_Full     (1 << 29)
#define SUPPORTED_56000baseLR4_Full     (1 << 30)

...
#define ADVERTISED_56000baseSR4_Full    (1 << 29)
#define ADVERTISED_56000baseLR4_Full    (1 << 30)

in the case of speed there is already a speed_hi, so that gets us 32
bits of speed expressed in Mb/s

These fast networks create so many problems ;-)

There are two u32's reserved at the end of ethtool_cmd.

Suggestions?
