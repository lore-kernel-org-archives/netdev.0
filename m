From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/1] drivers: net: davinci_cpdma: acknowledge interrupt
 properly
Date: Thu, 31 Jan 2013 15:47:20 +0530
Message-ID: <510A44B0.30200@ti.com>
References: <1359575813-15703-1-git-send-email-mugunthanvnm@ti.com> <EF466712-C5FF-4A91-BDF3-477559B02705@dominion.thruhere.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <panto@antoniou-consulting.com>
To: Koen Kooi <koen@dominion.thruhere.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <EF466712-C5FF-4A91-BDF3-477559B02705@dominion.thruhere.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/31/2013 1:33 AM, Koen Kooi wrote:
> Op 30 jan. 2013, om 20:56 heeft Mugunthan V N <mugunthanvnm@ti.com> het volgende geschreven:
>
>> CPDMA interrupts are not properly acknowledged which leads to interrupt
>> storm, only cpdma interrupt 0 is acknowledged in Davinci CPDMA driver.
>> Changed cpdma_ctlr_eoi api to acknowledge 1 and 2 interrupts which are
>> used for rx and tx respectively.
> A brief inspection shows that this still isn't following the TRM, but Pantelis' patch does. Can you please fix this driver to follow the TRM and make it work on both PG1.0 and PG2.0 instead of papering over bugs instead of fixing them properly?
Existing driver implementation is also complies with TRM. What Pantelis 
added
additionally are non-napi implementation, handled cpdma processed tx and rx
processing separately and renamed wr_reg as per TRM naming convention.. 
Also he
has added a dummy reading tx/rx stat which is mentioned in TRM, but this 
stat
is required only when using multichannel for data transfer. Current 
implementation
of CPSW driver uses only channel 0 of Tx and Rx channels respectively 
for transmission
and reading stat doesn't gets any effect in interrupt acknowledgment.

Since both tx and rx are processed in same napi api, so i have added 
interrupt
acknowledgment to the same existing api.

Regards
Mugunthan V N
