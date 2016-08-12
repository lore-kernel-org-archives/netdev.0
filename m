From: Pavel Andrianov <andrianov@ispras.ru>
Subject: A potential data race in drivers/net/ethernet/smsc/smc91c92_cs.ko
Date: Fri, 12 Aug 2016 12:54:07 +0300
Message-ID: <f6391dbe-c692-d88c-9877-79270fce397b@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Antonio Quartulli <a@unstable.cc>, Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Vaishali Thakkar <vaishali.thakkar@oracle.com>,
	ldv-project@linuxtesting.org
To: Felipe Balbi <felipe.balbi@linux.intel.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

There is a potential data race in drivers/net/ethernet/smsc/smc91c92_cs.ko.
Regard two threads:

Thread 1 			Thread 2
				...
...				->smc_open
->smc_tx_timeout		  ->mod_timer 	
   -> smc_reset			    ->media_check - timer function
     -> smc_set_xcvr		      ->smc_set_xcvr	

In this case the struct 'smc' is modified from two threads 
simultaneously. Likely, the first thread should acquire the same 
spinlock smc->lock as the second thread in media_check.

-- 
Pavel Andrianov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: andrianov@ispras.ru
