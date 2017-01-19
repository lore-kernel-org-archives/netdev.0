From: Vineeth Remanan Pillai <vineethp@amazon.com>
Subject: Re: [PATCH v2] xen-netfront: Fix Rx stall during network stress and
 OOM
Date: Thu, 19 Jan 2017 09:17:09 -0800
Message-ID: <47b20f33-2fbe-c4f7-68dc-994073dd5105@amazon.com>
References: <1484771149-12699-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
 <66b10c64-936a-8001-6855-2ff1ed626642@amazon.com>
 <20170119.121137.735637643552808729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170119.121137.735637643552808729.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/19/2017 09:11 AM, David Miller wrote:
> From: Vineeth Remanan Pillai <vineethp@amazon.com>
> Date: Thu, 19 Jan 2017 08:35:39 -0800
>
>> From: Vineeth Remanan Pillai <vineethp@amazon.com>
>>
>> During an OOM scenario, request slots could not be created as skb
>> allocation fails. So the netback cannot pass in packets and netfront
>> wrongly assumes that there is no more work to be done and it disables
>> polling. This causes Rx to stall.
>>
>> The issue is with the retry logic which schedules the timer if the
>> created slots are less than NET_RX_SLOTS_MIN. The count of new request
>> slots to be pushed are calculated as a difference between new req_prod
>> and rsp_cons which could be more than the actual slots, if there are
>> unconsumed responses.
>>
>> The fix is to calculate the count of newly created slots as the
>> difference between new req_prod and old req_prod.
>>
>> Signed-off-by: Vineeth Remanan Pillai <vineethp@amazon.com>
>> Reviewed-by: Juergen Gross <jgross@suse.com>
>> ---
>> Changes in v2:
>> 	- Removed the old implementation of enabling polling on
>> 	  skb allocation error.
>> 	- Corrected the refill timer logic to schedule when newly
>> 	  created slots since last push is less than NET_RX_SLOTS_MIN.
> Your postings aren't showing up on vger.kernel.org at all.
>
> Are you getting a bounce message back?  I can only assume you are triggering
> one of the various content filters we have.
>
I haven't received any bounce messages till now. The mail showed up
in xen-devel after about 8 hours yesterday. Not sure what is happening
with vger.kernel.org. My initial patch showed up in all the mailing 
list. The
only difference is, I switched to a machine running a later version of git.

Should I try sending it once again?

Thanks
