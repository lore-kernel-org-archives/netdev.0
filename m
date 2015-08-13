From: Philip Downey <pdowney@Brocade.com>
Subject: RE: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Thu, 13 Aug 2015 14:48:23 +0000
Message-ID: <57f72e6a6f024628bd18ef4b139ac31e@EMEAWP-EXMB12.corp.brocade.com>
References: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
 <20150812.164519.1783786478654950784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:26651 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752973AbbHMOsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 10:48:41 -0400
In-Reply-To: <20150812.164519.1783786478654950784.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David
Thanks for taking the time to review and comment.
This is my first upstream request so please forgive any ignorance on my part.   I have added a new proposed commit wording below with a view to agreeing the content before resubmitting the patch.
I hope it is sufficient to address your concerns.

   IGMP: Inhibit reports for local multicast groups
    
    The range of addresses between 224.0.0.0 and 224.0.0.255
    inclusive, is reserved for the use of routing protocols and other
    low-level topology discovery or maintenance protocols, such as
    gateway discovery and group membership reporting.  Multicast
    routers should not forward any multicast datagram with   destination
    addresses in this range, regardless of its TTL.

    Currently, IGMP reports are generated for this reserved range of
    addresses even though a router will ignore this information since
    it has no purpose.  However, the presence of reserved group
    addresses in an IGMP membership report uses up network bandwidth
    and can also obscure addresses of interest when inspecting
    membership reports using packet inspection or debug messages.

    IGMP reports for local multicast groups can now be inhibited by means
    of a system control variable (setting the value to zero).
    
    To retain backwards compatibility the previous behaviour is retained by
    default on system boot.
    
    Signed-off-by: Philip Downey <pdowney@brocade.com>


Regards

Philip

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, August 13, 2015 12:45 AM
> To: Philip Downey
> Cc: kuznet@ms2.inr.ac.ru; jmorris@namei.org; yoshfuji@linux-ipv6.org;
> kaber@trash.net; linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
> 
> From: Philip Downey <pdowney@brocade.com>
> Date: Wed, 12 Aug 2015 17:13:53 +0100
> 
> > IGMP reports are generated for link local multicast groups (224.0.0.1
> > - 224.0.0.255) used by the routing protocols such as RIP, OSPF etc.
> > In general routers do not generate reports for local multicast groups.
> >
> > IGMP reports for local multicast groups can now be inhibited by means
> > of a system control variable (setting the value to zero).
> >
> > To retain backwards compatibility the previous behaviour is retained
> > by default on system boot.
> >
> > Signed-off-by: Philip Downey <pdowney@brocade.com>
> 
> I'm always hesitent to apply patches like this.
> 
> I can't even understand from your explanation:
> 
> 1) what about local reporting behavior is so bad
> 
> 2) why you want to inhibit them at all
> 
> For example, this:
> 
> > In general routers do not generate reports for local multicast groups.
> 
> Doesn't tell me anything.  You need to go into more detail about this, and
> explain the situation sufficiently.
