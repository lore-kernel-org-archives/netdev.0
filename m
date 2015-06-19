From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight
 tunnel encap attributes
Date: Fri, 19 Jun 2015 16:19:13 +0100
Message-ID: <558432F1.5040209@brocade.com>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>,
	<tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:13688 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751902AbbFSPT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 11:19:28 -0400
In-Reply-To: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/06/15 05:49, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Introduces two netlink attributes RTA_ENCAP_TYPE and
> RTA_ENCAP to support attaching encap information to ipv4 routes.

Surely RTA_ENCAP_TYPE should be part of RTA_ENCAP, since the type 
doesn't make sense without the data and vice versa?

>
> RTA_ENCAP is a nested attribute as suggested by Thomas
> (and also as Robert had it in his series). RTA_ENCAP
> netlink policy is declared by the light weight tunnel
> drivers that support this encap type.
>
> fib code calls the following for each nexthop:
> 	- new route handler:
> 		lwt build state (that parses RTA_ENCAP and returns
> 	  	lwt state that lives in every fib_nh)
> 	- del dump hanlder:
> 		lwt release handler to release lwt state data
> 	- route dump hanlder:
> 		lwt dump encap to fill RTA_ENCAP data
> 	- during input route lookup
> 		sets dst->output to lwtunnel_output which
> 		in turn calls the corresponding lwt tunnel
> 		output function which applies the required
> 		encap and xmits the packet
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks,
Rob
