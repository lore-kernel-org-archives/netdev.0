From: Amir Vadai <amirv@mellanox.com>
Subject: Re: Face some error after applying commit 7dfa4b414d4(net/mlx4_en:
 Code cleanups in tx path)
Date: Mon, 10 Nov 2014 10:00:21 +0200
Message-ID: <54607095.6070302@mellanox.com>
References: <20141108025758.GA13875@richard> <CANn89i+ekXHJSePzQ0rWx2KKqwYGTrok3-ZZ1RdEygVJcGDqRQ@mail.gmail.com> <20141110015933.GB6294@richard> <1415587574.13896.131.camel@edumazet-glaptop2.roam.corp.google.com> <20141110054010.GA3224@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:36476 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750890AbaKJIBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 03:01:16 -0500
In-Reply-To: <20141110054010.GA3224@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2014 7:40 AM, Wei Yang wrote:
> On Sun, Nov 09, 2014 at 06:46:14PM -0800, Eric Dumazet wrote:
>> On Mon, 2014-11-10 at 09:59 +0800, Wei Yang wrote:
>>> On Fri, Nov 07, 2014 at 07:38:15PM -0800, Eric Dumazet wrote:
>>>> On Fri, Nov 7, 2014 at 6:57 PM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>>>>> Eric and Amir
>>>>>

[...]

>>>
>>
>> Okay, your message was not clear : I thought you had a compilation error
>> on current tree.
>>
>> The true story of these patches is that Mellanox split an initial big
>> chunk [1] I gave into multiple patches.
>>
>> Maybe they missed that one patch did not actually compile.
>>
>> [1] https://patchwork.ozlabs.org/patch/394256/
>>
>> Now, it is done, there is nothing we can do.
>>
>> I'll let Mellanox comment, but it looks like your hardware does not like
>> something.
>>
>> Have you tried to disable Blue Frame ?
>>
> 
> Yep, looks the PF works fine. But the current FW I can't just enable the PF.
> 
> How to disable Blue Frame? I am not clear about this.
> 
Hi,

Lets see that we're on the same page here:
1. There was a compilation problem that you fixed (Yes, it was my fault
- I just discovered it a minute after the code was applied).
2. When you're using SR-IOV, during initialization, you get a CQE error
with syndrome 0x2 on one of the probed VF's.
3. Regarding the BlueFlame - I don't see how it is related to the issue
that you see. But it is a very easy experiment. Issue: "ethtool
--set-priv-flags eth1 blueflame off"

Please send me the module parameters you used when loading mlx4_core, a
full dmesg with both mlx4_core and mlx4_en loading.

Amir.
