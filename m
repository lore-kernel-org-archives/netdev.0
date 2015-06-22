From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight
 tunnel encap attributes
Date: Sun, 21 Jun 2015 19:30:56 -0700
Message-ID: <55877360.609@cumulusnetworks.com>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com> <20150621202017.GA4228@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34211 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbbFVCa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 22:30:58 -0400
Received: by pdbki1 with SMTP id ki1so128539296pdb.1
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 19:30:58 -0700 (PDT)
In-Reply-To: <20150621202017.GA4228@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/15, 1:20 PM, Thomas Graf wrote:
> On 06/18/15 at 09:49pm, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Introduces two netlink attributes RTA_ENCAP_TYPE and
>> RTA_ENCAP to support attaching encap information to ipv4 routes.
>>
>> RTA_ENCAP is a nested attribute as suggested by Thomas
>> (and also as Robert had it in his series). RTA_ENCAP
>> netlink policy is declared by the light weight tunnel
>> drivers that support this encap type.
>>
>> fib code calls the following for each nexthop:
>> 	- new route handler:
>> 		lwt build state (that parses RTA_ENCAP and returns
>> 	  	lwt state that lives in every fib_nh)
>> 	- del dump hanlder:
>> 		lwt release handler to release lwt state data
>> 	- route dump hanlder:
>> 		lwt dump encap to fill RTA_ENCAP data
>> 	- during input route lookup
>> 		sets dst->output to lwtunnel_output which
>> 		in turn calls the corresponding lwt tunnel
>> 		output function which applies the required
>> 		encap and xmits the packet
> Thanks for putting in the flag! I think introducing helpers for the
> lwt work would help as it can centralize the required ifdef magic
> and be defined as a static inline nop or macros so the core routing
> code doesn't need to have ifdefs spread around.
yes that would be better, let me see what I can do.

thanks,
