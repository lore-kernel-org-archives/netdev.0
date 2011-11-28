From: Martin Casado <casado@nicira.com>
Subject: Re: [ovs-dev] [GIT PULL v2] Open vSwitch
Date: Mon, 28 Nov 2011 07:50:36 -0800
Message-ID: <4ED3ADCC.604@nicira.com>
References: <20111123075433.GA7928@gondor.apana.org.au>  <1322050976.2039.125.camel@mojatatu>  <20111128130409.GB16828@gondor.apana.org.au>  <1322488954.7338.66.camel@mojatatu>  <4ED3A85A.1030003@nicira.com> <1322494356.7338.75.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, dev@openvswitch.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-roam1.Stanford.EDU ([171.67.219.88]:60173 "EHLO
	smtp-roam.stanford.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753228Ab1K1Puk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 10:50:40 -0500
In-Reply-To: <1322494356.7338.75.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> This is a common misunderstanding about OpenFlow.  It does not require
>> the first packet of each flow to go to the controller.
> I am reading this to mean that the switch CPU will resolve things?
> Typically those tend to be tiny cpus.
>
No, no datapath traffic leaves the switching chip.  Generally 
controllers calculate full forwarding tables using wildcarded rules and 
use low priority rules to handle exception traffic (still keeping it on 
the datapath).
>
>> In fact, no
>> production system I'm aware of does this.  Generally OpenFlow-based
>> solutions targeted at large environments (e.g. data center, or WAN)
>> send only traditional control traffic to the controller (e.g. BGP or
>> OSPF), or none at all.
> Even OSPF or BGP  would be problematic imo if the architecture doesnt
> allow prioritization of some form towards the controller.
Indeed.  Controllers generally implement such prioritization by using 
OpenFlow forwarding rules that match on control traffic and explicitly 
set the controller as the destination.  This allows the application of 
any QoS primitives within OpenFlow to control traffic.

best,
.martin
>
> cheers,
> jamal
>
>


-- 
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Martin Casado
Nicira Networks, Inc.
www.nicira.com
cell: 650-776-1457
~~~~~~~~~~~~~~~~~~~~~~~~~~~
