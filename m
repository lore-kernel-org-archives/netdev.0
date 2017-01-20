From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net 0/2] net: Fix oops on state free after lwt module
 unload
Date: Fri, 20 Jan 2017 20:21:45 +0000
Message-ID: <916bada8-febc-7da9-022a-34dee4010e8b@brocade.com>
References: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
 <20170120.120321.688277769193451439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tom@herbertland.com>,
        <roopa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:37263 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753079AbdATUWC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:22:02 -0500
In-Reply-To: <20170120.120321.688277769193451439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/01/17 17:03, David Miller wrote:
> From: Robert Shearman <rshearma@brocade.com>
> Date: Wed, 18 Jan 2017 15:32:01 +0000
>
>> This patchset fixes an oops in lwtstate_free and a memory leak that
>> would otherwise be exposed by ensuring that references are taken on
>> modules that need to stay around to clean up lwt state. To faciliate
>> this all ops that implement destroy_state and that can be configured
>> to build as a module are changed specify the owner module in the
>> ops. The intersection of those two sets is just ila at the moment.
>
> Two things:
>
> 1) Under no circumstances should we allow a lwtunnel ops implementing
>    module to unload while there is a rule using those ops which is
>    alive.
>
>    Therefore, we should not special case the destroy op.  We should
>    unconditionally grab the module reference.
>
> 2) Please add the new 'owner' field and add an appropriate assignment
>    for ops->owner to _every_ lwtunnel implementation, and do so in
>    your first patch.  Please do not only do this for ILA.
>
> Thanks.

Very clear, makes sense, will do.

Thanks,
Rob
