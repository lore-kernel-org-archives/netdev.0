From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: add suspend_halted module param
Date: Mon, 24 Feb 2014 11:37:15 -0800
Message-ID: <CAGVrzcaOSMQWJ69KHJ7TH0_BN9D-O4uoL=fLWDoE=xFdV4RJ4w@mail.gmail.com>
References: <1393174719-20806-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <20140224191554.GC29288@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140224191554.GC29288@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-02-24 11:15 GMT-08:00 Andrew Lunn <andrew@lunn.ch>:
> On Sun, Feb 23, 2014 at 05:58:39PM +0100, Sebastian Hesselbarth wrote:
>> commit 1211ce53077164e0d34641d0ca5fb4d4a7574498
>>   ("net: phy: resume/suspend PHYs on attach/detach")
>> introduced a feature to suspend PHYs when entering halted state.
>>
>> Unfortunately, not all bootloaders properly power-up PHYs on reset
>> and fail to access ethernet because the PHY is still powered down.
>>
>> Therefore, we add a boolean module parameter suspend_halted with
>> default value of true. Disabling that parameter prevents PHYs from
>> being suspended when entering halted state.
>
> Hi Sebastian
>
> Am i doing something silly here?

Could the PHY be already suspended during your initial boot? If that
is the case, the first time we all phy_suspend() the flag is true, we
suspend it, and we never wake it again despite changing
suspend_halted. Does it work better if you specify this module
parameter on the initial kernel boot command-line?

>
> root@qnap:/sys/module/libphy/parameters# cat suspend_halted
> Y
> root@qnap:/sys/module/libphy/parameters# echo N > suspend_halted
> root@qnap:/sys/module/libphy/parameters# cat suspend_halted
> N
> root@qnap:/sys/module/libphy/parameters# reboot
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
>
>      Andrew



-- 
Florian
