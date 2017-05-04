From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 9/9] ipvlan: introduce individual MAC addresses
Date: Thu, 4 May 2017 18:43:45 +0200
Message-ID: <20170504184345.3f9afb8e@griffin>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
        <20170427145142.15830-10-marco.chiappero@intel.com>
        <1493310033.27948.3.camel@redhat.com>
        <1493310219.27948.5.camel@redhat.com>
        <695CDAEB5A6CE2498DE413F2A9AA82960915DF0C@IRSMSX101.ger.corp.intel.com>
        <1493741366.32411.7.camel@redhat.com>
        <695CDAEB5A6CE2498DE413F2A9AA82960915EF08@IRSMSX101.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "Grandhi, Sainath" <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>
To: "Chiappero, Marco" <marco.chiappero@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50164 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753246AbdEDQnt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 12:43:49 -0400
In-Reply-To: <695CDAEB5A6CE2498DE413F2A9AA82960915EF08@IRSMSX101.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 May 2017 09:37:00 +0000, Chiappero, Marco wrote:
> This looks conceptually wrong. Yes, ipvlan works at L3 (which is an
> implementation detail anyway), but slaves are Ethernet interfaces and
> should behave as much as possible as such regardless, with an
> individual MAC address assigned.

Isn't the proper fix then converting ipvlan interfaces to be L3 only
interfaces? I.e., ARPHRD_NONE? There's not much ipvlan can do with
arbitrary Ethernet frames anyway. Of course, a flag to switch to the
new behavior would be needed in order to preserve backwards
compatibility.

This patchset looks very wrong. For proper support of multiple MAC
addresses, we have macvlan and it's pointless to add that to ipvlan.
And doing some kind of weird MAC NAT in ipvlan just to satisfy broken
tools that can't cope with multiple interfaces with the same MAC address
is wrong, too. Those tools are already broken anyway, there's nothing
preventing anyone to set the same MAC address to multiple interfaces.
I suppose those tools don't work with bonding and bridge, either?

> So, either we fix this by forcing slaves to stay in sync with master,

Yes, that's the correct behavior. Well, at least as correct as one can
get with the ipvlan broken design of pretending that an interface is L2
when in fact, it is not.

 Jiri
