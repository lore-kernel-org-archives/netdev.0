From: Ben Greear <greearb@candelatech.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 20:45:07 -0700
Message-ID: <4DC611C3.7070607@candelatech.com>
References: <891B02256A0667292521A4BF@Ximines.local>	 <1304770926.2821.1157.camel@edumazet-laptop>	 <0F4A638C2A523577CDBC295E@Ximines.local>	 <1304783684.9216.2.camel@edumazet-laptop>	 <4DC571F1.2020108@candelatech.com>	 <1304786277.3207.12.camel@edumazet-laptop>	 <4DC57702.4090606@candelatech.com> <1304787065.3207.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36735 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381Ab1EHDpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 23:45:19 -0400
In-Reply-To: <1304787065.3207.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2011 09:51 AM, Eric Dumazet wrote:
> Le samedi 07 mai 2011 =C3=A0 09:44 -0700, Ben Greear a =C3=A9crit :
>> On 05/07/2011 09:37 AM, Eric Dumazet wrote:
>>> Le samedi 07 mai 2011 =C3=A0 09:23 -0700, Ben Greear a =C3=A9crit :
>>>
>>>> I wonder if it would be worth having a 'delete me soon'
>>>> method to delete interfaces that would not block on the
>>>> RCU code.
>>>>
>>>> The controlling programs could use netlink messages to
>>>> know exactly when an interface was truly gone.
>>>>
>>>> That should allow some batching in the sync-net logic
>>>> too, if user-space code deletes 1000 interfaces very
>>>> quickly, for instance...
>>>>
>>>
>>> I suggested in the past to have an extension of batch capabilities,=
 so
>>> that one kthread could have 3 separate lists of devices being destr=
oyed
>>> in //,
>>>
>>> This daemon would basically loop on one call to synchronize_rcu(), =
and
>>> transfert list3 to deletion, list2 to list3, list1 to list2, loop,
>>> eventually releasing RTNL while blocked in synchronize_rcu()
>>>
>>> This would need to allow as you suggest an asynchronous deletion me=
thod,
>>> or use a callback to wake the process blocked on device delete.
>>
>> I'd want to at least have the option to not block the calling
>> process...otherwise, it would be a lot more difficult to
>> quickly delete 1000 interfaces.  You'd need 1000 threads, or
>> sockets, or something to parallelize it otherwise, eh?
>
> Yes, if you can afford not receive a final notification of device bei=
ng
> fully freed, it should be possible.

Well, I'd hope to get a netlink message about the device being deleted,=
 and
after that, be able to create another one with the same name, etc.

Whether the memory is actually freed in the kernel or not wouldn't matt=
er
to me...

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
