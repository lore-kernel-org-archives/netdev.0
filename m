From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Thu, 26 Mar 2015 17:10:47 +0200
Message-ID: <55142177.9080705@cloudius-systems.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com> <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com> <55113B9B.3090308@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com> <5511B5AE.1090905@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274DD2@FMSMSX105.amr.corp.intel.com> <55127F8D.3070309@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250275B81@FMSMSX105.amr.corp.intel.com> <551317DE.90500@cloudius-systems.com> <551322F2.5020101@redhat.com> <5513D2C9.7010907@cloudius-systems.com> <55141A4B.1040903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:32947 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975AbbCZPKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 11:10:50 -0400
Received: by wgbcc7 with SMTP id cc7so67095269wgb.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 08:10:49 -0700 (PDT)
In-Reply-To: <55141A4B.1040903@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/26/15 16:40, Alexander Duyck wrote:
>
> On 03/26/2015 02:35 AM, Vlad Zolotarov wrote:
>>
>>
>> On 03/25/15 23:04, Alexander Duyck wrote:
>>>
>>> On 03/25/2015 01:17 PM, Vlad Zolotarov wrote:
>>>>
>>>>
>>>> On 03/25/15 20:35, Tantilov, Emil S wrote:
>>>>>> -----Original Message-----
>>>>>> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
>>>>>> Sent: Wednesday, March 25, 2015 2:28 AM
>>>>>> Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>>>>>
>>>>
> <snip>
>>>>>
>>>>>> Perhaps storing the RSS key and the table is better option than 
>>>>>> having to invoke the mailbox on every read.
>>>>>> I don't think this could work if I understand your proposal 
>>>>>> correctly.
>>>>>> The only way to cache the result that would decrease the number 
>>>>>> of mbox
>>>>>> transactions would be to cache it in the VF. But how could i 
>>>>>> invalidate
>>>>>> this cache if the table content has been changed by a PF? I think 
>>>>>> the
>>>>>> main source of a confusion here is that u assume that PF driver is a
>>>>>> Linux ixgbe driver that doesn't support an indirection table 
>>>>>> change at
>>>>>> the moment. As I have explained above - this should not be assumed.
>>>>> You keep mentioning other drivers - what other driver do you mean?
>>>>> All the PF drivers that enable SRIOV are maintained and supported 
>>>>> by Intel.
>>>>>
>>>>> For HW older than X550 we can simply not allow the RSS hash to be 
>>>>> modified if the driver is loaded in SRIOV mode.
>>>>> This way the RSS info can be read once the driver is loaded. For 
>>>>> X550 this can all be done in the VF, so you can avoid calling the 
>>>>> mailbox altogether.
>>>>> I understand this is a bit limiting, but this is due to HW 
>>>>> limitation anyway (VFs do not have their own RSS config).
>>>>
>>>> Let me remind u that Linux, FreeBSD, XEN  and DPDK PF drivers are 
>>>> all open source so u can't actually go and "not allow" things. ;) 
>>>> And although Intel developers contribute most of the code there are 
>>>> and will be other contributors too so I doubt the proposed above 
>>>> approach fits the open source spirit well. ;)
>>>
>>> Actually these drivers already support multiple OSes just fine. The 
>>> part where I think you are confused is that you assume they all use 
>>> the same Mailbox API which they likely wouldn't.  I would suggest 
>>> taking a look at ixgbe_pfvf_api_rev in mbx.h of the VF driver. 
>>> Different OSes have different things that can be supported, so for 
>>> example the ixgbe_mbox_api_20 is reserved for a Solaris based PF/VF 
>>> combination.  I would suspect that FreeBSD will likely have to 
>>> conform to the existing APIs, or report that it only supports a 
>>> different version of the mailbox API.
>>
>> I didn't assume a common API at all. My point was that u can't just 
>> go and "forbid" standard things like changing the indirection table 
>> in the open source project(s). Therefore u shouldn't assume it and 
>> thus caching the indirection table doesn't seem a future-proof 
>> solution to me.
>>
>
> The point was the current driver doesn't provide any such option. If 
> you plan on adding it, then add it first and then we can talk about 
> it.  Otherwise it isn't a requirement for any current solution that 
> you might implement.  That was the point I was trying to get across.  
> My advice is to avoid scoping in features that aren't there.  If you 
> want to go ahead and add it then do so, but otherwise don't limit 
> implementation by things that have not yet been added.

Let me remind that the above is said in the context of caching. The 
indirection table modification is an important tool for load balancing. 
The fact that ixgbe hasn't implemented it yet doesn't seem justified by 
anything but by the fact that u just haven't got to it yet. If u won't 
do it sometimes soon - somebody else will. That's why IMHO caching in VF 
is not the most wise direction since I'm not aware of a tool how PF can 
indicate to VF (driver) to invalidate it. All this in the context of 
82599 and x540 devices of course.


>
>>
>>>
>>>>
>>>> The user should actually not query the indirection table and a hash 
>>>> key too often. And if he/she does - it should be his/her problem.
>>>> However, if like with the ixgbevf_set_num_queues() u insist on your 
>>>> way of doing this (on caching the indirection table and hash key) - 
>>>> then please let me know and I will add it. Because, frankly, I care 
>>>> about the PF part of this series much more than for the VF part... ;)
>>>
>>> I would say you don't need to cache it, but for 82599 and x540 there 
>>> isn't any need to store more than 3 bits per entry, 384b, or 12 
>>> DWORDs for the entire RETA of the VF since the hardware can support 
>>> at most 8 queues w/ SR-IOV.  Then you only need one message instead 
>>> of 3 which will reduce quite a bit of the complication with all of 
>>> this.
>>>
>>> Also it might make more sense to start working on displaying this on 
>>> the PF before you start trying to do this on the VF. As far as I 
>>> know ixgbe still doesn't have this functionality and it would make 
>>> much more sense to enable that first on ixgbe before you start 
>>> trying to find a way to feed the data to the VF.
>>
>> Let's agree on the next steps:
>>
>> 1. I'll reduce the series scope to 82599 and x540 devices.
>
> For mailbox implementation that is okay, my advice for the x550 would 
> be to just read the registers.  They should already be defined in the 
> driver so it is just a matter of reversing the process for writing the 
> RETA.  You should have a solid grasp of that once you implement the 
> solution for the PF.

The problem is that I have no means to validate the solution - I have 
only x540 devices (nor specs). I'd prefer not to work in darkness and 
let u, guys, do it...

>
>> 2. I'll add the same ethtool operations I've already added to VF to PF
>>    devices as well.
>
> Yes, I would recommend PF first, and then VF.  The PF allows for a 
> much simpler approach, and you will likely have a better idea of the 
> solution for X550.  For the most part you can probably just copy the 
> code already in igb.



>
>> 3. I'll implement the compression the Alex so desperately wants... ;)
>
> I've done enough of these mailbox type setups on this hardware to 
> realize that you don't want to be dealing with a multi-part message.  
> It will make things so much easier for you to have this processed as a 
> single message.
>
>> 4. I won't implement the caching of the indirection and RSS hash key
>>    query results in the VF level.
>
> The idea with caching is to keep the number of messages across the 
> mailbox to a minimum.  Compressing it down to 3 bits per entry will 
> help some, but I am not sure if that is enough to completely mitigate 
> the need for caching.  For now though the caching isn't a must-have, 
> and it won't be needed for x550 since it can access the table 
> directly.  The main thing I would recommend keeping an eye on would be 
> how long it will take to complete the messages necessary to get the 
> ethtool info.  If there are any scenarios where things take more than 
> 1 second then I would say we are taking too long and we would have to 
> look into caching because we want to avoid holding the rtnl lock for 
> any extended period of time.

I've described the limitations the caching approach imposes above. I 
suggest we follow your approach here - solve the problems when they 
arrive. ;) I haven't succeeded to make it take as long as even near one 
second.

>
> My advice is get the PF patches in first, then we can look at trying 
> to get feature parity on the VF.

"feature parity on the VF"?

I'll send the patches later today. I'll incorporate the new PF code into 
the existing series.

>
> - Alex
