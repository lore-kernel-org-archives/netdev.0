From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: ravb: Possible Regression In "net: phy: Avoid polling PHY with PHY_IGNORE_INTERRUPTS"
Date: Tue, 16 Feb 2016 22:35:03 -0800
Message-ID: <A565D475-0B4E-4BE5-A748-2E20E4DDAD71@gmail.com>
References: <20160216032642.GE23315@verge.net.au> <CAMuHMdXvnY0i69jSfxk_2K0Ac0PtjF7G7QMXKOh6KOLQE8MsMg@mail.gmail.com> <56C302CF.2030300@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <56C302CF.2030300@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On February 16, 2016 3:06:55 AM PST, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
>Hello.
>
>On 2/16/2016 10:42 AM, Geert Uytterhoeven wrote:
>
>>> I have observed what appears to be a regression in the ravb ethernet
>driver
>>> caused by d5c3d84657db ("net: phy: Avoid polling PHY with
>>> PHY_IGNORE_INTERRUPTS").
>>>
>>> When booting net-next configured with the ARM64 defconfig on the
>Renesas
>>> r8a7795/salvator-x I see the following and the ravb is unable to
>access the
>>> network. With the above mentioned patch reverted I am able to boot
>to
>>> user-space using nfsroot.
>>
>> The ravb interrupt is connected to a GPIO controller, which is
>> runtime-suspended and thus not serving the interrupt.

OK that makes complete sense then, is your patch going to make it into an upcoming v4.5-rc pull request or should we think about having the ravb driver re-assign its phydev->irq to PHY_POLL for the time being?

>>
>> Cfr. "[PATCH/RFC] gpio: rcar: Add Runtime PM handling for interrupts"
>> (http://www.spinics.net/lists/linux-renesas-soc/msg00532.html).
>>
>> I assume it worked before as the PHY driver polled the PHY instead of
>relying
>> solely on the interrupt.
>
>   Correct. BTW, I'm going to look at handling AVB_PHY_INT in the ravb 
>driver, thus removing the need for routing it to the GPIO controller
>now that 
>phylib allows this again...

That sounds like a better solution if the PHY interrupt is consistently and uniformly available on these boards. 

-- 
Florian
