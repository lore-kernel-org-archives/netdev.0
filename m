From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sun, 27 Feb 2005 22:44:20 +0000
Message-ID: <42224D44.6080904@phekda.gotadsl.co.uk>
References: <42208D83.80803@phekda.gotadsl.co.uk> <20050226182658.GB13230@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jdmason@us.ibm.com>, netdev@oss.sgi.com, jgarzik@pobox.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050226182658.GB13230@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Francois Romieu wrote:
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
> [...]
> 
>>@@ -1531,6 +1620,11 @@ static int rtl8169_open(struct net_devic
>> 	if (retval < 0)
>> 		goto err_free_rx;
>> 
>>+	tp->nic_stats = pci_alloc_consistent(pdev, R8169_STATS_BYTES,
>>+					     &tp->nic_stats_addr);
>>+	if (!tp->nic_stats)
>>+		goto err_free_nic_stats;
>>+
>> 	INIT_WORK(&tp->task, NULL, dev);
>> 
>> 	rtl8169_hw_start(dev);
>>@@ -1541,6 +1635,10 @@ static int rtl8169_open(struct net_devic
>> out:
>> 	return retval;
>> 
>>+err_free_nic_stats:
>>+	pci_free_consistent(pdev, R8169_STATS_BYTES, tp->nic_stats,
>>+			    tp->nic_stats_addr);
>>+
> 
> 
> You don't want to free it it was not allocated. Please undo the previous
> step (init_ring probably) and:
[snip]

Oops, thanks for spotting that. I'll fix it for the next revision of the 
patch.

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
