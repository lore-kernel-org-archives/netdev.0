From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Thu, 13 Aug 2015 19:01:37 +0200
Message-ID: <20150813170137.GE32627@lunn.ch>
References: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
 <20150812.164519.1783786478654950784.davem@davemloft.net>
 <57f72e6a6f024628bd18ef4b139ac31e@EMEAWP-EXMB12.corp.brocade.com>
 <20150813160626.GF32484@lunn.ch>
 <b50a97f544f5437fb18df1cb5b6b6533@EMEAWP-EXMB12.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Philip Downey <pdowney@Brocade.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b50a97f544f5437fb18df1cb5b6b6533@EMEAWP-EXMB12.corp.brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 13, 2015 at 04:52:32PM +0000, Philip Downey wrote:
> Hi Andrew
> IGMP snooping is designed to prevent hosts on a local network from receiving traffic for a multicast group they have not explicitly joined.   Link-Local multicast traffic should not have an IGMP client since it is reserved for routing protocols.  One would expect that IGMP snooping needs to ignore local multicast traffic in the reserved range intended for routers since there should be no IGMP client to make "join" requests.

The point of this patch is that Linux is sending out group membership
for these addresses, it is acting as a client. What happens with a
switch which is applying IGMP snooping to link-local multicast groups?
You turn on this feature, and you no longer get your routing protocol
messages.

I had a quick look at RFC 3376. The only mention i spotted for not
sending IGMP messages is:

   The all-systems multicast address, 224.0.0.1, is handled as a special
   case.  On all systems -- that is all hosts and routers, including
   multicast routers -- reception of packets destined to the all-systems
   multicast address, from all sources, is permanently enabled on all
   interfaces on which multicast reception is supported.  No IGMP
   messages are ever sent regarding the all-systems multicast address.

IGMP v2 has something similar:

   The all-systems group (address 224.0.0.1) is handled as a special
   case.  The host starts in Idle Member state for that group on every
   interface, never transitions to another state, and never sends a
   report for that group.

But i did not find anything which says all other link-local addresses
don't need member reports. Did i miss something?

      Andrew
