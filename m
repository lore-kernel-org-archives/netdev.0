From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: phy: add suspend_halted module param
Date: Tue, 25 Feb 2014 23:38:52 +0100
Message-ID: <530D1B7C.2090506@gmail.com>
References: <1393174719-20806-1-git-send-email-sebastian.hesselbarth@gmail.com> <20140224191554.GC29288@lunn.ch>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140224191554.GC29288@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/24/2014 08:15 PM, Andrew Lunn wrote:
> On Sun, Feb 23, 2014 at 05:58:39PM +0100, Sebastian Hesselbarth wrote:
>> commit 1211ce53077164e0d34641d0ca5fb4d4a7574498
>>    ("net: phy: resume/suspend PHYs on attach/detach")
>> introduced a feature to suspend PHYs when entering halted state.
>>
>> Unfortunately, not all bootloaders properly power-up PHYs on reset
>> and fail to access ethernet because the PHY is still powered down.
>>
>> Therefore, we add a boolean module parameter suspend_halted with
>> default value of true. Disabling that parameter prevents PHYs from
>> being suspended when entering halted state.
>
> Am i doing something silly here?
>
> root@qnap:/sys/module/libphy/parameters# cat suspend_halted
> Y
> root@qnap:/sys/module/libphy/parameters# echo N > suspend_halted
> root@qnap:/sys/module/libphy/parameters# cat suspend_halted
> N
> root@qnap:/sys/module/libphy/parameters# reboot

Just to be sure, can you ifconfig up the interface before reboot?
The PHY could already be powered-down, if the interface is down.

> ...
> ...
>
> Net:   egiga0 [PRIME]
> Hit any key to stop autoboot:  0
> Send Cmd : 0x68 to UART1
> egiga0 no link
> Using egiga0 device
> TFTP from server 10.0.0.1; our IP address is 10.0.0.2
> Filename 'uImage-qnap'.
> Load address: 0x800000
> Loading: T T
>
> Does not seem to work.

I tested the patch on Topkick (w/ 88E1318S, 0x0141 0x0e90) which
bootloader is also affected.

Both, libphy.suspend_halted=0 as kernel boot parameter and sysfs
procedure above successfully prevent the PHY from being powered
down. After reboot, u-boot tftpboot works as expected.

Sebastian
