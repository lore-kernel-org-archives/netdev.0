From: Ross Brattain <ross.b.brattain@intel.com>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Mon, 17 Oct 2011 13:53:23 -0700
Message-ID: <20111017135323.00003ee5@unknown>
References: <20111004041444.793960297@vyatta.com>
	<20111004041509.292932641@vyatta.com>
	<CAF5U64AYRhZ1e0=-RhSemgaOnewTQSpAoRY2FUrFr252PG98Pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ed Swierk <eswierk@bigswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14760 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990Ab1JQUxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 16:53:25 -0400
In-Reply-To: <CAF5U64AYRhZ1e0=-RhSemgaOnewTQSpAoRY2FUrFr252PG98Pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2011 07:35:53 -0700
Ed Swierk <eswierk@bigswitch.com> wrote:

> Why is forwarding LLDP (01-80-C2-00-00-0E) frames forbidden? I'm
> testing LLDP in a virtual topology and need the bridge to forward
> them.
> 
> If we're worried about standards, there is justification for allowing
> forwarding of LLDP frames. 802.1d-2005 specifies two classes of
> bridge, customer (C-VLAN) and provider (S-VLAN). Customer bridge is
> just new terminology for what was previously just called an
> 802.1d-compliant bridge, while provider bridge is a new class that
> transparently forwards certain control frames.

01-80-C2-00-00-0E should not pass the physical link.  If it does it will affect PFC 802.1Qbb and ETS 802.1Qaz.

802.1AB-2009 is more specific.  See Table 7-1 Group MAC addresses used by LLDP:

Nearest bridge: 01-80-C2-00-00-0E
Propagation constrained to a single physical link; stopped by all types of bridge

Nearest non-TPMR bridge: 01-80-C2-00-00-03
Propagation constrained by all bridges other than TPMRs; intended for use within provider bridged networks

Nearest Customer Bridge: 01-80-C2-00-00-00
Propagation constrained by customer bridges; this gives the same coverage as a customer-customer MACSec connection


--
Ross
