From: Philip Downey <pdowney@Brocade.com>
Subject: RE: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Thu, 13 Aug 2015 16:52:32 +0000
Message-ID: <b50a97f544f5437fb18df1cb5b6b6533@EMEAWP-EXMB12.corp.brocade.com>
References: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
 <20150812.164519.1783786478654950784.davem@davemloft.net>
 <57f72e6a6f024628bd18ef4b139ac31e@EMEAWP-EXMB12.corp.brocade.com>
 <20150813160626.GF32484@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150813160626.GF32484@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew
IGMP snooping is designed to prevent hosts on a local network from receiving traffic for a multicast group they have not explicitly joined.   Link-Local multicast traffic should not have an IGMP client since it is reserved for routing protocols.  One would expect that IGMP snooping needs to ignore local multicast traffic in the reserved range intended for routers since there should be no IGMP client to make "join" requests.

Regards

Philip

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, August 13, 2015 5:06 PM
> To: Philip Downey
> Cc: David Miller; kuznet@ms2.inr.ac.ru; jmorris@namei.org; yoshfuji@linux-
> ipv6.org; kaber@trash.net; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org
> Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
> 
> On Thu, Aug 13, 2015 at 02:48:23PM +0000, Philip Downey wrote:
> > Hi David
> > Thanks for taking the time to review and comment.
> > This is my first upstream request so please forgive any ignorance on my
> part.   I have added a new proposed commit wording below with a view to
> agreeing the content before resubmitting the patch.
> > I hope it is sufficient to address your concerns.
> >
> >    IGMP: Inhibit reports for local multicast groups
> >
> >     The range of addresses between 224.0.0.0 and 224.0.0.255
> >     inclusive, is reserved for the use of routing protocols and other
> >     low-level topology discovery or maintenance protocols, such as
> >     gateway discovery and group membership reporting.  Multicast
> >     routers should not forward any multicast datagram with   destination
> >     addresses in this range, regardless of its TTL.
> >
> >     Currently, IGMP reports are generated for this reserved range of
> >     addresses even though a router will ignore this information since
> >     it has no purpose.
> 
> Hi Philip
> 
> What about switches which are doing IGMP snooping?
> 
>      Andrew
