From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: ravb: Possible Regression In "net: phy: Avoid polling PHY with
 PHY_IGNORE_INTERRUPTS"
Date: Tue, 16 Feb 2016 14:06:55 +0300
Message-ID: <56C302CF.2030300@cogentembedded.com>
References: <20160216032642.GE23315@verge.net.au>
 <CAMuHMdXvnY0i69jSfxk_2K0Ac0PtjF7G7QMXKOh6KOLQE8MsMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXvnY0i69jSfxk_2K0Ac0PtjF7G7QMXKOh6KOLQE8MsMg@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/16/2016 10:42 AM, Geert Uytterhoeven wrote:

>> I have observed what appears to be a regression in the ravb ethernet driver
>> caused by d5c3d84657db ("net: phy: Avoid polling PHY with
>> PHY_IGNORE_INTERRUPTS").
>>
>> When booting net-next configured with the ARM64 defconfig on the Renesas
>> r8a7795/salvator-x I see the following and the ravb is unable to access the
>> network. With the above mentioned patch reverted I am able to boot to
>> user-space using nfsroot.
>
> The ravb interrupt is connected to a GPIO controller, which is
> runtime-suspended and thus not serving the interrupt.
>
> Cfr. "[PATCH/RFC] gpio: rcar: Add Runtime PM handling for interrupts"
> (http://www.spinics.net/lists/linux-renesas-soc/msg00532.html).
>
> I assume it worked before as the PHY driver polled the PHY instead of relying
> solely on the interrupt.

    Correct. BTW, I'm going to look at handling AVB_PHY_INT in the ravb 
driver, thus removing the need for routing it to the GPIO controller now that 
phylib allows this again...

> Gr{oetje,eeting}s,
>
>                          Geert

MBR, Sergei
