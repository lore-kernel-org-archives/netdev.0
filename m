From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v4] mpls: support for dead routes
Date: Tue, 24 Nov 2015 16:46:59 +0000
Message-ID: <56549483.3080600@brocade.com>
References: <1448082968-63882-1-git-send-email-roopa@cumulusnetworks.com> <56531F96.2030704@brocade.com> <5653DC6E.9090204@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ebiederm@xmission.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:37521 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753558AbbKXQrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 11:47:14 -0500
In-Reply-To: <5653DC6E.9090204@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/11/15 03:41, roopa wrote:
> On 11/23/15, 6:15 AM, Robert Shearman wrote:
>> On 21/11/15 05:16, Roopa Prabhu wrote:
>>> +        if (!rt_new) {
>>> +            pr_warn("mpls_ifdown: kmemdup failed\n");
>>
>> It isn't safe to leave the current route untouched if the net device is being deleted, since a nexthop will be left holding a stale pointer to it. Perhaps delete the route entirely in that case?
> I would not delete the route. But, Would it be bad modifying rt in that case (ie when rt_new is not possible) ?. It is a remote case..and the side effect being the datapath will not see the changes atomically.

No, that sounds fine to me as long as RCU_INIT_POINTER is used.

Thanks,
Rob
