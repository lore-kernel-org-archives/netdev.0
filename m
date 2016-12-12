From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/2] Add ethtool set regs support
Date: Mon, 12 Dec 2016 09:00:15 -0800
Message-ID: <3f2b4059-d4a3-1ea6-6122-51b810b1995b@gmail.com>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
 <20161207024143.GA655@lunn.ch>
 <CALzJLG8nGU-29VoKDtdaoFuG7zfTvTTu14T91+PMxcJH-GG2bw@mail.gmail.com>
 <20161211152229.GC29761@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "John W . Linville" <linville@tuxdriver.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36188 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753247AbcLLRAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 12:00:17 -0500
Received: by mail-pf0-f196.google.com with SMTP id c4so4642313pfb.3
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 09:00:17 -0800 (PST)
In-Reply-To: <20161211152229.GC29761@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2016 07:22 AM, Andrew Lunn wrote:
> On Sun, Dec 11, 2016 at 02:18:00PM +0200, Saeed Mahameed wrote:
>> On Wed, Dec 7, 2016 at 4:41 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>>> On Wed, Dec 07, 2016 at 12:33:08AM +0200, Saeed Mahameed wrote:
>>>> Hi Dave,
>>>>
>>>> This series adds the support for setting device registers from user
>>>> space ethtool.
>>>
>>> Is this not the start of allowing binary only drivers in user space?
>>>
>>
>> It is not, we want to do same as set_eeprom already do,
>> Just set some HW registers, for analysis/debug/tweak/configure HW
>> dependent register for the NIC netdev sake.
> 
> Mellanox has a good reputation of open drivers. However, this API
> sounds like it would be the first step towards user space
> drivers. This is an API which can peek and poke registers, so it
> probably could be mis-used to put part of a driver in user
> space. Hence we should avoid this sort of API to start with.

I don't necessarily share your concerns here on the proprietary vs. open
source driver, because this interface is limited to the register space,
not the data path, there is only a handful of things you can do here,
but getting a NIC to work, is not probably one of them.

My concern is more with the support/debugging aspect, if someone starts
tweaking a gazillion of registers through that interface, and I have no
way to tell, how am I going to support that? Of course, the first step
is: have you tried to turn it on and off again, and see if this is
reproducible, but what if I was asked/told to tweak this or that value
first, etc... it can be hard to collect the exact state in which a NIC
is at the time of the problem.

NB: on the proprietary driver side, you can already mmap() the PCI
device's space and write an entire user-space based driver (DPDK) and
bypass the kernel for most things, ethtool -D is not much worse here
since it just offers a subset (and a small one) of that.
-- 
Florian
