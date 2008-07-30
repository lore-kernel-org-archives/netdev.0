From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Wed, 30 Jul 2008 16:00:28 +0200
Message-ID: <1217426429.30512.195.camel@ecld0pohly>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com>
	 <200807291849.24945.opurdila@ixiacom.com>
	 <1217410552.30512.144.camel@ecld0pohly>
	 <200807301638.54484.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46579 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757304AbYG3OCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 10:02:24 -0400
In-Reply-To: <200807301638.54484.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-30 at 16:38 +0300, Octavian Purdila wrote:
> On Wednesday 30 July 2008, Patrick Ohly wrote:
> 
> > It's the app which chooses when to enable the feature, so we need a way
> > to communicate that.
> 
> Ok, perhaps a new SIOCSHWTSTAMP ioctl? (or maybe we can piggy back on the 
> filter one with the HWTSTAMP_FILTER_NONE you proposed?)

I'm fine with just one ioctl and would prefer a generic SIOCSHWTSTAMP. I
would like to go even one step further than discussed so far and also
use it to enable TX time stamping. The reasoning is that the driver
might have to do some work (like initializing the NIC clock, setting up
NIC/system time comparison) both for TX and RX.

That means that we need two fields and defines for TX. Adding new fields
later on works, but having to support multiple different sizes in the
driver could get complicated, so I suggest to add at least a (currently
unused) flag field. Not sure what the usual convention is regarding the
type fields - char or int?

struct hwtstamp_config {
    char tx_type;
    char rx_filter_type;
    int flags;
};

/**
 * no outgoing packet will need hardware time stamping;
 * should a packet arrive which asks for it, no hardware
 * time stamping will be done
 */
#define HWTSTAMP_TX_OFF 0

/**
 * enables hardware time stamping for outgoing packets;
 * the sender of the packet decides which are to be 
 * time stamped
 */
#define HWSTAMP_TX_ON 1

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

