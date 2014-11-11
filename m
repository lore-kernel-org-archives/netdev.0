From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: Face some error after applying commit 7dfa4b414d4(net/mlx4_en:
 Code cleanups in tx path)
Date: Tue, 11 Nov 2014 09:57:05 +0800
Message-ID: <20141111015705.GA8470@richard>
References: <20141108025758.GA13875@richard>
 <CANn89i+ekXHJSePzQ0rWx2KKqwYGTrok3-ZZ1RdEygVJcGDqRQ@mail.gmail.com>
 <20141110015933.GB6294@richard>
 <1415587574.13896.131.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141110054010.GA3224@richard>
 <54607095.6070302@mellanox.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:36142 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbaKKB5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 20:57:13 -0500
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 11 Nov 2014 11:57:10 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 4F08F2BB0077
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 12:57:08 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAB1x2oN23855222
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 12:59:03 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAB1v6oj008831
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 12:57:07 +1100
Content-Disposition: inline
In-Reply-To: <54607095.6070302@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 10:00:21AM +0200, Amir Vadai wrote:
>On 11/10/2014 7:40 AM, Wei Yang wrote:
>> On Sun, Nov 09, 2014 at 06:46:14PM -0800, Eric Dumazet wrote:
>>> On Mon, 2014-11-10 at 09:59 +0800, Wei Yang wrote:
>>>> On Fri, Nov 07, 2014 at 07:38:15PM -0800, Eric Dumazet wrote:
>>>>> On Fri, Nov 7, 2014 at 6:57 PM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>>>>>> Eric and Amir
>>>>>>
>
>[...]
>
>>>>
>>>
>>> Okay, your message was not clear : I thought you had a compilation error
>>> on current tree.
>>>
>>> The true story of these patches is that Mellanox split an initial big
>>> chunk [1] I gave into multiple patches.
>>>
>>> Maybe they missed that one patch did not actually compile.
>>>
>>> [1] https://patchwork.ozlabs.org/patch/394256/
>>>
>>> Now, it is done, there is nothing we can do.
>>>
>>> I'll let Mellanox comment, but it looks like your hardware does not like
>>> something.
>>>
>>> Have you tried to disable Blue Frame ?
>>>
>> 
>> Yep, looks the PF works fine. But the current FW I can't just enable the PF.
>> 
>> How to disable Blue Frame? I am not clear about this.
>> 
>Hi,
>
>Lets see that we're on the same page here:
>1. There was a compilation problem that you fixed (Yes, it was my fault
>- I just discovered it a minute after the code was applied).
>2. When you're using SR-IOV, during initialization, you get a CQE error
>with syndrome 0x2 on one of the probed VF's.

>From the log, seems yes.

>3. Regarding the BlueFlame - I don't see how it is related to the issue
>that you see. But it is a very easy experiment. Issue: "ethtool
>--set-priv-flags eth1 blueflame off"

I tried to use this after mlx4_en is loaded, still see the CQE error.

>
>Please send me the module parameters you used when loading mlx4_core, a
>full dmesg with both mlx4_core and mlx4_en loading.

The command line I use is:
	modprobe mlx4_core num_vfs=1 probe_vf=1 port_type_array=2,2

The log I sent in the first mail is the full log, including the CQE error, one
warning in watchdog, and then print the CQE error periodicly. What else
message you would like me to capture?

And this error is reported from VF always. After the error, the other network
interface seems can't function.

>
>Amir.

-- 
Richard Yang
Help you, Help me
