From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 6pack,mkiss: fix lock inconsistency
Date: Fri, 01 Jul 2011 17:30:57 -0700 (PDT)
Message-ID: <20110701.173057.2255930046909364966.davem@davemloft.net>
References: <20110625163942.GB20976@linux-mips.org>
	<4E0DC4F3.6010203@free.fr>
	<201107012328.46256.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f6bvp@free.fr, ralf@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <201107012328.46256.arnd@arndb.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 1 Jul 2011 23:28:46 +0200

> Lockdep found a locking inconsistency in the mkiss_close function:
> 
>> kernel: [ INFO: inconsistent lock state ]
>> kernel: 2.6.39.1 #3
>> kernel: ---------------------------------
>> kernel: inconsistent {IN-SOFTIRQ-R} -> {SOFTIRQ-ON-W} usage.
>> kernel: ax25ipd/2813 [HC0[0]:SC0[0]:HE1:SE1] takes:
>> kernel: (disc_data_lock){+++?.-}, at: [<ffffffffa018552b>] mkiss_close+0x1b/0x90 [mkiss]
>> kernel: {IN-SOFTIRQ-R} state was registered at:
> 
> The message hints that disc_data_lock is aquired with softirqs disabled,
> but does not itself disable softirqs, which can in rare circumstances
> lead to a deadlock. 
> The same problem is present in the 6pack driver, this patch fixes both
> by using write_lock_bh instead of write_lock.
> 
> Reported-by: Bernard F6BVP <f6bvp@free.fr>
> Tested-by: Bernard F6BVP <f6bvp@free.fr>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Acked-by: Ralf Baechle<ralf@linux-mips.org>
> Cc: stable@kernel.org

Applied, thanks!
