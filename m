From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] qed: avoid possible stack overflow in
 qed_ll2_acquire_connection
Date: Fri, 20 Jan 2017 11:44:55 -0500 (EST)
Message-ID: <20170120.114455.431685285744854397.davem@davemloft.net>
References: <20170118145306.1004008-1-arnd@arndb.de>
        <20170118145306.1004008-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, Ram.Amrani@cavium.com,
        weiyongjun1@huawei.com, hare@suse.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118145306.1004008-2-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 18 Jan 2017 15:52:52 +0100

> struct qed_ll2_info is rather large, so putting it on the stack
> can cause an overflow, as this warning tries to tell us:
> 
> drivers/net/ethernet/qlogic/qed/qed_ll2.c: In function 'qed_ll2_start':
> drivers/net/ethernet/qlogic/qed/qed_ll2.c:2159:1: error: the frame size of 1056 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
> 
> qed_ll2_start_ooo() already uses a dynamic allocation for the structure
> to work around that problem, and we could do the same in qed_ll2_start()
> as well as qed_roce_ll2_start(), but since the structure is only
> used to pass a couple of initialization values here, it seems nicer
> to replace it with a different structure.
> 
> Lacking any idea for better naming, I'm adding 'struct qed_ll2_conn',
> which now contains all the initialization data, and this now simply
> gets copied into struct qed_ll2_info rather than assigning all members
> one by one.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
