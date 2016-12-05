From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Mon, 5 Dec 2016 23:37:09 +0100
Message-ID: <9a85da24-85cf-f94e-908f-a10eecac2369@gmx.de>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd> <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd> <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
 <20161205101516.GA24936@amd>
 <trinity-efd00e93-2b37-4543-a199-e2cbed9fe455-1480937999976@3capp-gmx-bs18>
 <20161205220221.GA19135@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161205220221.GA19135@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

On 05.12.2016 23:02, Pavel Machek wrote:
> 
> we need spin_lock_bh at minimum, as we are locking user context
> against timer.
> 
> Best regards,
> 									Pavel
> 

I was referring to stmmac_tx_clean() which AFAICS is only called from softirq context,
(one time in the timer handler and one time in napi poll handler) so a spin_lock() should
be sufficient. I cant see how this is called from userspace. If it were, a spin_lock_bh() had
to be used, of course.

Regards,
Lino 
