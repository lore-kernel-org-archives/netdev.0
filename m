From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Is there a preferred way to get the VXLAN port number?
Date: Wed, 27 Mar 2013 14:35:51 -0400
Message-ID: <OFDD155B0F.E457F85C-ON85257B3B.0065B415-85257B3B.00662700@us.ibm.com>
References: <51521B05.6060401@intel.com> <20130327105254.2e10de02@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org,
	pshelar@nicira.com, Stephen Hemminger <shemminger@vyatta.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:47160 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364Ab3C0Sv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:51:28 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 27 Mar 2013 12:51:25 -0600
In-Reply-To: <20130327105254.2e10de02@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 03/27/2013 01:52:54 PM:

> On Tue, 26 Mar 2013 15:02:45 -0700
> Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> 
> > I was wondering if someone would happen to know if there is already a
> > preferred way to get the VXLAN port number for things such as
> > configuring a device to recognize a VXLAN frame on receive for parsing
> > purposes?
> > 
> > I just wanted to check to make sure I hadn't missed something before
> > submitting a patch that would export a simple function for supplying 
the
> > vxlan_port value.

        To answer your question, though, the current vxlan can only listen
on one port per host, supplied with by a module parameter. You can find
what port it's listening on by:

cat /sys/modules/vxlan/parameters/udp_port

[which you can also read with a program, of course].

If multi-port server support is added, that should probably include the
port as part of the current "ip -d link show dev XXX" output, where other
per-device parameters are found.

                                                        +-DLS
