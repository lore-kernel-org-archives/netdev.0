From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: Face some error after applying commit 7dfa4b414d4(net/mlx4_en:
 Code cleanups in tx path)
Date: Tue, 11 Nov 2014 15:42:43 +0800
Message-ID: <20141111074243.GA25321@richard>
References: <20141108025758.GA13875@richard>
 <CANn89i+ekXHJSePzQ0rWx2KKqwYGTrok3-ZZ1RdEygVJcGDqRQ@mail.gmail.com>
 <20141110015933.GB6294@richard>
 <1415587574.13896.131.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141110054010.GA3224@richard>
 <54607095.6070302@mellanox.com>
 <20141111015705.GA8470@richard>
 <CAPcc5Ph-guxyUj96VQa1FqTsnwU3J8em4wv0E+ddYho71o0v4w@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, gerlitz.or@gmail.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:43748 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbaKKHmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 02:42:51 -0500
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 11 Nov 2014 17:42:49 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id F0F232BB0073
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 18:42:46 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAB7gXp116908440
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 18:42:33 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAB7gj4F010295
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 18:42:46 +1100
Content-Disposition: inline
In-Reply-To: <CAPcc5Ph-guxyUj96VQa1FqTsnwU3J8em4wv0E+ddYho71o0v4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 09:28:34AM +0200, Amir Vadai wrote:
>On Tue, Nov 11, 2014 at 3:57 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>> On Mon, Nov 10, 2014 at 10:00:21AM +0200, Amir Vadai wrote:
>>>On 11/10/2014 7:40 AM, Wei Yang wrote:
>>>> On Sun, Nov 09, 2014 at 06:46:14PM -0800, Eric Dumazet wrote:
>>>>> On Mon, 2014-11-10 at 09:59 +0800, Wei Yang wrote:
>>>>>> On Fri, Nov 07, 2014 at 07:38:15PM -0800, Eric Dumazet wrote:
>>>>>>> On Fri, Nov 7, 2014 at 6:57 PM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>>>>>>>> Eric and Amir
>>>>>>>>
>>>
>>>[...]
>>>
>>>>>>
>>>>>
>>>>> Okay, your message was not clear : I thought you had a compilation error
>>>>> on current tree.
>>>>>
>>>>> The true story of these patches is that Mellanox split an initial big
>>>>> chunk [1] I gave into multiple patches.
>>>>>
>>>>> Maybe they missed that one patch did not actually compile.
>>>>>
>>>>> [1] https://patchwork.ozlabs.org/patch/394256/
>>>>>
>>>>> Now, it is done, there is nothing we can do.
>>>>>
>>>>> I'll let Mellanox comment, but it looks like your hardware does not like
>>>>> something.
>>>>>
>>>>> Have you tried to disable Blue Frame ?
>>>>>
>>>>
>>>> Yep, looks the PF works fine. But the current FW I can't just enable the PF.
>>>>
>>>> How to disable Blue Frame? I am not clear about this.
>>>>
>>>Hi,
>>>
>>>Lets see that we're on the same page here:
>>>1. There was a compilation problem that you fixed (Yes, it was my fault
>>>- I just discovered it a minute after the code was applied).
>>>2. When you're using SR-IOV, during initialization, you get a CQE error
>>>with syndrome 0x2 on one of the probed VF's.
>>
>> From the log, seems yes.
>>
>>>3. Regarding the BlueFlame - I don't see how it is related to the issue
>>>that you see. But it is a very easy experiment. Issue: "ethtool
>>>--set-priv-flags eth1 blueflame off"
>>
>> I tried to use this after mlx4_en is loaded, still see the CQE error.
>>
>>>
>>>Please send me the module parameters you used when loading mlx4_core, a
>>>full dmesg with both mlx4_core and mlx4_en loading.
>>
>> The command line I use is:
>>         modprobe mlx4_core num_vfs=1 probe_vf=1 port_type_array=2,2
>>
>> The log I sent in the first mail is the full log, including the CQE error, one
>> warning in watchdog, and then print the CQE error periodicly. What else
>> message you would like me to capture?
>
>The log in the first mail has only mlx4_en logs. I would like to see
>the full log, that has mlx4_core messages too. And as Or suggested,
>debug_level=1 could be useful here too.
>

Ah, you need the log from mlx4_core too. Ok, I will do it again.

BTW, how to add the debug_level=1 in the command line? Like this?

modprobe mlx4_core num_vfs=1 probe_vf=1 port_type_array=2,2 debug_level=1

But for mlx4_en, I am not sure I could raise the debug level with ethtool,
since the ethernet driver may not work properly. Actually I am not sure how to
raise the level with ethtool. Could you give me an example?

>>
>> And this error is reported from VF always. After the error, the other network
>> interface seems can't function.
>>
>>>
>>>Amir.
>>
>> --
>> Richard Yang
>> Help you, Help me
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Richard Yang
Help you, Help me
