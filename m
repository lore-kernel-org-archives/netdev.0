From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: davinci_emac: Replace devm_request_irq with request_irq
Date: Thu, 6 Mar 2014 13:57:58 +0530
Message-ID: <5318318E.8030402@ti.com>
References: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jon Ringle <jon@ringle.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	<stable@vger.kernel.org>
To: Christian Riesch <christian.riesch@omicron.at>,
	<netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 05 March 2014 03:55 PM, Christian Riesch wrote:
> In commit 6892b41d9701283085b655c6086fb57a5d63fa47
>
> Author: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> Date:   Tue Jun 25 21:24:51 2013 +0530
> net: davinci: emac: Convert to devm_* api
>
> the call of request_irq is replaced by devm_request_irq and the call
> of free_irq is removed. But since interrupts are requested in
> emac_dev_open, doing ifconfig up/down on the board requests the
> interrupts again each time, causing devm_request_irq to fail.
>
> This patch reverts said commit partially: It changes the driver back
> to use request_irq instead of devm_request_irq, puts free_irq back in
> place, but keeps the remaining changes of the original patch.
>
> Reported-by: Jon Ringle <jon@ringle.org>
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
> Cc: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> Cc: <stable@vger.kernel.org>

Instead of moving back to request irq. can you move the devm interrupt
request code from open to probe so that the issue is fixed, IRQ will be
requested on module insert and IRQ will be free in module remove and
there will not be any failures in devm request irq while repeating
ifup/ifdown and also during module insert/remove.

Regards
Mugunthan V N
