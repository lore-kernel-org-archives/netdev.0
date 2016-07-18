From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net] bnxt_en: Fix potential race condition in bnxt_tx_enable()
Date: Mon, 18 Jul 2016 04:34:37 -0700
Message-ID: <CACKFLikGpJ8d7jiVFz=KoqNtOpct7owi1=_9FkAR4pS8otAj2g@mail.gmail.com>
References: <1468626125-31732-1-git-send-email-f.fainelli@gmail.com> <20160715.232048.1780795244111833927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: f.fainelli@gmail.com, Netdev <netdev@vger.kernel.org>,
	Jeffrey Huang <huangjw@broadcom.com>,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160715.232048.1780795244111833927.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 15, 2016 at 11:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Fri, 15 Jul 2016 16:42:01 -0700
>
>> @@ -4599,7 +4599,9 @@ static void bnxt_tx_enable(struct bnxt *bp)
>>       for (i = 0; i < bp->tx_nr_rings; i++) {
>>               txr = &bp->tx_ring[i];
>>               txq = netdev_get_tx_queue(bp->dev, i);
>> +             __netif_tx_lock(txq, smp_processor_id());
>>               txr->dev_state = 0;
>> +             __netif_tx_unlock(txq);
>
> You're going to have to explain how this could possibly cause a
> problem, because I'm pretty sure it can't.
>
> Either the reader sees 0, or non-zero, in this value.
>
> And adding locking around this assignment does not change that at all.

Florian, I agree with David.  The lock is not needed.  The lock in
bnxt_tx_disable() is also unnecessary and should be removed.  Thanks.
