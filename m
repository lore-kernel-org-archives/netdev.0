From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight
 tunnel encap attributes
Date: Fri, 19 Jun 2015 08:28:34 -0700
Message-ID: <55843522.7060804@cumulusnetworks.com>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com> <558432F1.5040209@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, tgraf@suug.ch, davem@davemloft.net,
	netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32913 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbbFSP2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 11:28:37 -0400
Received: by padev16 with SMTP id ev16so87504107pad.0
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 08:28:36 -0700 (PDT)
In-Reply-To: <558432F1.5040209@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/15, 8:19 AM, Robert Shearman wrote:
> On 19/06/15 05:49, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Introduces two netlink attributes RTA_ENCAP_TYPE and
>> RTA_ENCAP to support attaching encap information to ipv4 routes.
>
> Surely RTA_ENCAP_TYPE should be part of RTA_ENCAP, since the type 
> doesn't make sense without the data and vice versa?
I went back and forth on this. And started with what you are saying 
above. But then I wanted RTA_ENCAP netlink policy to be declared by 
individual lwtunnel drivers.
And to determine which RTA_ENCAP netlink policy to pick, you need to 
know the RTA_ENCAP policy type (or lwtunnel type)
which is encoded in RTA_ENCAP_TYPE. And I did not want to introduce 
another level of nest in RTA_ENCAP (because for nexthops we are already 
2 levels deep when parsing RTA_ENCAP).

Hence, fib code first looks for RTA_ENCAP and if RTA_ENCAP is specified, 
RTA_ENCAP_TYPE is a required attribute. My iproute2 patches handles this 
and makes sure
there is an  RTA_ENCAP_TYPE specified with RTA_ENCAP.

thanks,
Roopa
