From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Tue, 23 Feb 2016 18:07:08 +0100
Message-ID: <56CC91BC.1000505@stressinduktion.org>
References: <1456165924-14399-4-git-send-email-jiri@resnulli.us>
 <56CC41C8.10802@stressinduktion.org> <20160223122109.GD2140@nanopsycho.orion>
 <56CC5E65.40809@stressinduktion.org> <20160223142626.GF2140@nanopsycho.orion>
 <56CC77BB.60601@stressinduktion.org> <20160223153023.GJ2140@nanopsycho.orion>
 <56CC815D.9070009@stressinduktion.org>
 <20160223160458.GM2140@nanopsycho.orion>
 <56CC8C93.1090207@stressinduktion.org>
 <20160223165523.GO2140@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39951 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751872AbcBWRHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 12:07:16 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 863E820BC2
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:07:13 -0500 (EST)
In-Reply-To: <20160223165523.GO2140@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.02.2016 17:55, Jiri Pirko wrote:
> Tue, Feb 23, 2016 at 05:45:07PM CET, hannes@stressinduktion.org wrote:
>> On 23.02.2016 17:04, Jiri Pirko wrote:
>>> Tue, Feb 23, 2016 at 04:57:17PM CET, hannes@stressinduktion.org wrote:
>>>> On 23.02.2016 16:30, Jiri Pirko wrote:
>>>>> Tue, Feb 23, 2016 at 04:16:11PM CET, hannes@stressinduktion.org wrote:
>>>>>
>>>>> <snip>
>>>>>
>>>>>>>> 1) is easily solvable, just drop the ifindex style attributes and always
>>>>>>>> force the user to enter the bus and bus-topology id.
>>>>>>>
>>>>>>> But why? Use can easily get that info and map it to devlink index. It
>>>>>>> aligns with nl80211 iface.
>>>>>>>
>>>>>>> Do you really want to do commands like:
>>>>>>> myhost:~$ dl dev show pci_0000:01:00.0
>>>>>>> ?
>>>>>>
>>>>>> Yes, exactly I would. I would put them into a boot-up script based on my
>>>>>> system configuration and can be sure it will work the next boot, too, and
>>>>>> adapt them when I replace the hardware or do some configuration changes.
>>>>>>
>>>>>> I think sysadmins or scripts are the primary users of this interface not
>>>>>> kernel developers which switch their settings around all the time, no?
>>>>>
>>>>> I can easily add this to the userspace tool to accept "pci_0000:01:00.0"
>>>>> format and to map it internally to devlink index. No problem.
>>>>
>>>> I argue for this stable topology identifier to be the default. Especially if
>>>> you add device info before the actual module is loaded (this is during
>>>> initramfs, when udev cannot rename devlink names to stable ones), a user has
>>>> to deal with pre-devlink-ids before rename and after. Do you have plans how
>>>> to address that?
>>>
>>> You can still access devlink using pci_addr using dl. I don't see a
>>> problem.
>>
>> I don't really see a reason why the devlink indexes/names exist inside the
>> kernel instead of a stable topology identifier. They confuse users and add
>> more unnecessary code to the kernel. Shells have environment variables for
>> that. ;) This is a low-level kernel setting tool IMHO.
>>
>> I just see the problem that users use the devlink* names and we get reports
>> because stuff breaks because they don't use the stable identifiers. That is
>> all.
>>
>
> you can have stable devlink name using udev. For pre-udev usage, you can
> use pci address directly. I don't like to use pci address for every
> dl command. I would like to have some more convenient name handle -
> devlink name.

Okay then - I was not sure if this low-level kernel command line tool 
deserves changes to the whole booting infrastructure to make it safe to use.

>>>> Current initramfs for stable interface names uses EUI48 based mac addresses
>>>> most of the time and udev runs then after the pivot_root.
>>>>
>>>> The devlink names can easily be aliases in user space.
>>>
>>> I don't want to store them anywhere. I just use "dl" tool and pass the
>>> name there.
>>
>> Sorry?
>
> you said - "The devlink names can easily be aliases in user space." -
> where do you want to store them?

You can easily store them in your shell environment or add a feature to 
the dl command to read aliases from a file (will be much more simple 
than walking all devlinks and checking for a match if you implement it 
the reverse way).

Note, if you want to have kernel provided names, they need to be stored 
in user space anyway because of udev renaming and the persisting database.

Bye,
Hannes
