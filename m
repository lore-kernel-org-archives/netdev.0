From: Jeff Garzik <jgarzik@pobox.com>
Subject: [code] new NAPI helper functions
Date: Tue, 18 Feb 2003 01:54:55 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E51D8BF.1020804@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020102020808000908050304"
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020102020808000908050304
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here are some functions in tg3, that I would like to eventually make 
available to all net drivers (and other net stack users).

--------------020102020808000908050304
Content-Type: text/x-csrc;
 name="x.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.c"


/* these three netif_xxx funcs should be moved into generic net layer */
static void netif_poll_disable(struct net_device *dev)
{
	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
		current->state = TASK_INTERRUPTIBLE;
		schedule_timeout(1);
	}
}

static inline void netif_poll_enable(struct net_device *dev)
{
	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
}

/* same as netif_rx_complete, except that local_irq_save(flags)
 * has already been issued
 */
static inline void __netif_rx_complete(struct net_device *dev)
{
	if (!test_bit(__LINK_STATE_RX_SCHED, &dev->state)) BUG();
	list_del(&dev->poll_list);
	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
}


--------------020102020808000908050304--

