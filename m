From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: latest net-next: iwlwifi: reproducible SOFTIRQ-unsafe lock order
 detected
Date: Tue, 27 May 2014 20:38:12 +0200
Message-ID: <5384DB94.9050303@hartkopp.net>
References: <538232C5.7000306@hartkopp.net> <1401213672.5367.260.camel@edumazet-glaptop2.roam.corp.google.com> <1DC40B07CD6EC041A66726C271A73AE61B79892E@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"'johannes@sipsolutions.net'" <johannes@sipsolutions.net>
To: "Berg, Johannes" <johannes.berg@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.161]:57755 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbaE0SiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 14:38:15 -0400
In-Reply-To: <1DC40B07CD6EC041A66726C271A73AE61B79892E@IRSMSX102.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yep! That fixed it.

Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>

Btw. this issue is in net-next.

Regards,
Oliver


On 27.05.2014 20:03, Berg, Johannes wrote:
>> Bug added in commit ea68f46070c7bae608c619ae048f0ad995db74c3
>> ("iwlwifi: pcie: clarify TX queue need_update handling")
>>
>> Please try :
>>
>> diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c
>> b/drivers/net/wireless/iwlwifi/pcie/tx.c
>> index dde6031f4257..309a13caddcd 100644
>> --- a/drivers/net/wireless/iwlwifi/pcie/tx.c
>> +++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
>> @@ -338,12 +338,12 @@ void iwl_pcie_txq_check_wrptrs(struct iwl_trans
>> *trans)
>>  	for (i = 0; i < trans->cfg->base_params->num_of_queues; i++) {
>>  		struct iwl_txq *txq = &trans_pcie->txq[i];
>>
>> -		spin_lock(&txq->lock);
>> +		spin_lock_bh(&txq->lock);
> 
> Yeah, we have the same commit in the tree:
> 
> commit d090f878b0084344812dc7bb086e98cd24572e58
> Author: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> Date:   Tue May 13 08:10:51 2014 +0300
> 
>     iwlwifi: pcie: disable BHs in iwl_pcie_txq_check_wrptrs
> 
> I'm not sure why it hasn't hit net.git, I no longer maintain iwlwifi.git.
> 
> johannes
> 
