From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: forcedeth: cat /sys/class/net/eth0/carrier = Invalid argument
Date: Mon, 22 Mar 2010 21:07:12 -0700
Message-ID: <4BA83E70.4060906@gmail.com>
References: <4BA7AA92.5040400@gmail.com> <20100322.205144.256859987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100322.205144.256859987.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/22/2010 08:51 PM, David Miller wrote:
> From: "Justin P. mattock"<justinmattock@gmail.com>
> Date: Mon, 22 Mar 2010 10:36:18 -0700
>
>> I've pushed my kernel from the latest HEAD to 2.6.31
>> and am still seeing:
>> cat /sys/class/net/eth0/carrier
>> cat: carrier: Invalid argument
>>
>> with my other machine using sky2
>> the same results is:
>> cat /sys/class/net/eth0/carrier
>> 0
>>
>> is there anything on this? before I start
>> a bisect.(looking through bugzilla, I couldn't
>> see anything related).
>
> A device is not able to indicate carrier accurately when
> the device is not currently running.
>
> So you will get an -EINVAL until the device is brought up.

ah.. the machine was up and running but nothing was running
(no dhclient, streaming music, etc..)
now
just ran the machine with ethernet,(up and running) and carrier reported 1

>
> The reason is that most drivers don't even probe the link
> or negotiate link speed and flow control until the device
> is brought up.  Many don't even power up the PHY when the
> device is down, in order to save power.
>
> So the behavior you observe is completely expected.
>


cool, this had me confused.

Thanks for the info on this..
(no bisect for this).


Justin P. Mattock
