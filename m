From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: set random switch address
Date: Thu, 12 Oct 2017 15:43:10 -0700
Message-ID: <b845912e-a65a-6800-82e7-b2d26cd29d4e@gmail.com>
References: <20171012221009.14615-1-vivien.didelot@savoirfairelinux.com>
 <b9aecb73-b240-7b59-4315-ea87868396cd@gmail.com>
 <87k200vvsl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k200vvsl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/2017 03:35 PM, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> On 10/12/2017 03:10 PM, Vivien Didelot wrote:
>>> An Ethernet switch may support having a MAC address, which can be used
>>> as the switch's source address in transmitted full-duplex Pause frames.
>>>
>>> If a DSA switch supports the related .set_addr operation, the DSA core
>>> sets the master's MAC address on the switch.
>>>
>>> This won't make sense anymore in a multi-CPU ports system, because there
>>> won't be a unique master device assigned to a switch tree.
>>
>> Thus far, everything you have said is true, but why we should do it,
>> that is: what if we don't, needs to be explained. Does that create a
>> problem with the generation of pause frames throughout the switch fabric?
>>
>>>
>>> To fix this, assign a random MAC address to the switch chip instead.
>>
>> Maybe this is something that should be removed entirely from the DSA
>> core and pushed into the individual switch drivers instead. dsa_loop
>> implements it for code coverage, but that does not do anything.
>>
>> set_addr is confusing in that you may think it could be used to program
>> the switch with the MAC address of the CPU/management port such that you
>> can disable MAC address learning on said port, but in fact, that's not
>> how it is used.
> 
> You are correct. So what I can do is assign a random MAC address in the
> Marvell driver, remove the .set_addr implementation of mv88e6xxx and
> dsa_loop, and finally remove this code from DSA core completely.

Works for me, thanks!
-- 
Florian
