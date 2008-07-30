From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Wed, 30 Jul 2008 16:38:54 +0300
Message-ID: <200807301638.54484.opurdila@ixiacom.com>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com> <200807291849.24945.opurdila@ixiacom.com> <1217410552.30512.144.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:6309 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753227AbYG3NlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 09:41:24 -0400
In-Reply-To: <1217410552.30512.144.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 July 2008, Patrick Ohly wrote:

> It's the app which chooses when to enable the feature, so we need a way
> to communicate that.

Ok, perhaps a new SIOCSHWTSTAMP ioctl? (or maybe we can piggy back on the 
filter one with the HWTSTAMP_FILTER_NONE you proposed?)

> > Ok, I see... How about adding a new SIOCSHWTSTAMPFILTER ioctl:
> >
> > #define HWTSTAMP_FILTER_PTP_L2 0x01
> > #define HWTSTAMP_FILTER_PTP_L4 0x02
> > ...
> > struct hwtstamp_filter {
> > 	char type;
> > };
> >
> > If needed we could later expand hwtstamp_filter to include ether_types,
> > ip_types, udp/tcp ports, etc.
>
> Yes, that'll work. Regarding the design of the ioctl() call and its
> parameter, how do we preserve backwards compatibility as new fields get
> added?
>

I think we could simply add more fields in the structure since they will only 
be used with new commands. If the app know about the new command than it will 
know to use the new structure layout.

> The initial list of defines could be:
<snip>
> I prefer an enumeration over flags because by design, only valid
> combinations are possible.
>

I agree.

Thanks,
tavi
