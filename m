From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: allocate mac filtering pending list
 in PAGE_SIZE increments
Date: Tue, 20 Sep 2016 14:46:28 -0400
Message-ID: <57E18404.1010409@akamai.com>
References: <cover.1474060371.git.jbaron@akamai.com>
 <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
 <BL2PR07MB2306CEA6AD75D9D4EB77FB1F8DF50@BL2PR07MB2306.namprd07.prod.outlook.com>
 <57E02F82.9060903@akamai.com>
 <063D6719AE5E284EB5DD2968C1650D6DB01046DB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:46114 "EHLO
        prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752541AbcITSqb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 14:46:31 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB01046DB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/20/2016 07:30 AM, David Laight wrote:
> From: Jason Baron
>> Sent: 19 September 2016 19:34
> ...
>>
>> sizeof(struct bnx2x_mcast_list_elem) = 24. So there are 170 per
>> page on x86. So if we want to fit 2,048 elements, we need 12 pages.
>
> If you only need to save the mcast addresses you could use a 'heap'
> that requires no overhead per entry and gives you O(log) lookup.
> 6 bytes per entry is 682 in a 4k page.
>
> 	David
>

Indeed, that would save space here.

Based on Yuval's comments it sounds as though he agrees that it makes 
sense to go beyond a page (even if we get 682 per page as you suggest), 
when configuring these mac filters. So we would then have to allocate 
and manage the page pointers. Currently, there is a list_head per entry 
to manage the macs as a linked list. The patch I proposed continues to 
use that same data structure, thus it will not add to the memory 
footprint, it only proposes to break that footprint up into PAGE_SIZE 
chunks.

So I think the change you suggest can be viewed as an additional 
enhancement here, and also note that the memory allocations here are 
short-lived. That is, they only exist in memory until the NIC is 
re-configured.

Thanks,

-Jason
