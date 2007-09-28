From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] [PATCH v3] iw_cxgb3: Support"iwarp-only"interfacesto
 avoid 4-tuple conflicts.
Date: Fri, 28 Sep 2007 14:46:55 -0500
Message-ID: <46FD5A2F.7010409@opengridcomputing.com>
References: <20070923203649.8324.64524.stgit@dell3.ogc.int><46FBF8AF.9040700@ichips.intel.com><C98692FD98048C41885E0B0FACD9DFB805187514@exnane01.hq.netapp.com> <000101c8013a$41b374f0$a7cc180a@amr.corp.intel.com> <C98692FD98048C41885E0B0FACD9DFB80518755A@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sean Hefty <sean.hefty@intel.com>,
	Sean Hefty <mshefty@ichips.intel.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Kanevsky, Arkady" <Arkady.Kanevsky@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:36103 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752802AbXI1Tqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 15:46:55 -0400
In-Reply-To: <C98692FD98048C41885E0B0FACD9DFB80518755A@exnane01.hq.netapp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Kanevsky, Arkady wrote:
> Sean,
> IB aside,
> it looks like an ULP which is capable of being both RDMA aware and RDMA
> not-aware,
> like iSER and iSCSI, NFS-RDMA and NFS, SDP and sockets, 
> will be treated as two separete ULPs.
> Each has its own IP address, since there is a different IP address for
> iWARP
> port and "regular" Ethernet port. So it falls on the users of ULPs to
> "handle" it
> via DNS or some other services.
> Is this "acceptable" to users? I doubt it.
> 
> Recall that ULPs are going in opposite directions by having a different
> port number for RDMA aware and RDMA unaware versions of the ULP.
> This way, ULP "connection manager" handles RDMA-ness under the covers,
> while users plug an IP address for a server to connect to.
> Thanks,

Arkady, I'm confused about how this proposed design changes the behavior 
of the ULPs that run on TCP and iWARP.  I don't see much difference from 
the point of view of the ULPs.

The NFS-RDMA server, for example, will not need to change since it binds 
to address 0.0.0.0 which will translate into a bind/listen on the 
specific iwarp address for each iwarp device on the rdma side, and 
address 0.0.0.0 for the TCP side.

Am I missing your point?

The real pain, IMO, with this solution is that it FORCES the admins to 
use 2 subnets when 1 is sufficient if the net maintainers would unify 
the port space...

Steve.



> 
> Arkady Kanevsky                       email: arkady@netapp.com
> Network Appliance Inc.               phone: 781-768-5395
> 1601 Trapelo Rd. - Suite 16.        Fax: 781-895-1195
> Waltham, MA 02451                   central phone: 781-768-5300
>  
> 
>> -----Original Message-----
>> From: Sean Hefty [mailto:sean.hefty@intel.com] 
>> Sent: Thursday, September 27, 2007 3:12 PM
>> To: Kanevsky, Arkady; Sean Hefty; Steve Wise
>> Cc: netdev@vger.kernel.org; rdreier@cisco.com; 
>> linux-kernel@vger.kernel.org; general@lists.openfabrics.org
>> Subject: RE: [ofa-general] [PATCH v3] iw_cxgb3: 
>> Support"iwarp-only"interfacesto avoid 4-tuple conflicts.
>>
>>> What is the model on how client connects, say for iSCSI, when client 
>>> and server both support, iWARP and 10GbE or 1GbE, and would like to 
>>> setup "most" performant "connection" for ULP?
>> For the "most" performance connection, the ULP would use IB, 
>> and all these problems go away.  :)
>>
>> This proposal is for each iwarp interface to have its own IP 
>> address.  Clients would need an iwarp usable address of the 
>> server and would connect using rdma_connect().  If that call 
>> (or rdma_resolve_addr/route) fails, the client could try 
>> connecting using sockets, aoi, or some other interface.  I 
>> don't see that Steve's proposal changes anything from the 
>> client's perspective.
>>
>> - Sean
>> _______________________________________________
>> general mailing list
>> general@lists.openfabrics.org
>> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>>
>> To unsubscribe, please visit 
>> http://openib.org/mailman/listinfo/openib-general
>>
