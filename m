From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Mon, 19 Dec 2016 23:49:25 +0100
Message-ID: <f007ba4c-71ea-0abf-8715-be7b0bec6080@gmx.de>
References: <20161209112142.GA22710@amd>
 <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de> <20161211201104.GB20574@amd>
 <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de> <20161215210324.GA13878@amd>
 <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
 <6f43eac8-754b-cfa2-371d-050701deb4cd@gmx.de> <20161217173150.GA20231@amd>
 <20161218001507.GA5343@electric-eye.fr.zoreil.com>
 <a2cbcfcd-f377-565c-a21c-3daa3abce519@gmx.de> <20161218183010.GA7886@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161218183010.GA7886@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 18.12.2016 19:30, Pavel Machek wrote:
> Hi!
> 
>> > - e1efa87241272104d6a12c8b9fcdc4f62634d447
>> 
>> Yep, a sync of the dma descriptors before the hardware gets ownership of the tx tail
>> idx is missing in the stmmac, too.
> 
> I can reproduce failure with 4.4 fairly easily. I tried with dma_
> variant of barriers, and it failed, too
> 
> [ 1018.410012] stmmac: early irq
> [ 1023.939702] fpga_cmd_read:wait_event timed out!
> [ 1033.128692] ------------[ cut here ]------------
> [ 1033.133329] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:303
> dev_watchdog+0x264/0x284()
> [ 1033.141748] NETDEV WATCHDOG: eth0 (socfpga-dwmac): transmit queue 0
> timed out
> [ 1033.148861] Modules linked in:

This watchdog warning clearly says that for some reason the tx queue was stopped
but never woken up in a certain timespan (5 sec in our case, which is a lot).

Does this occur after the queue has been stopped and woken up again a few times or
is it already the first time the queue is stopped (and never woken up)? 

Regards,
Lino
