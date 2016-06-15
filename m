From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/5] genirq: implement support for runtime switch to
 threaded irqs
Date: Wed, 15 Jun 2016 22:50:45 +0800
Message-ID: <201606152202.XrIIy7vV%fengguang.wu@intel.com>
References: <5104d67d1f9370e9fe3790164d07c628b727d382.1465996447.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="envbJBWh7q8WU6mo"
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5104d67d1f9370e9fe3790164d07c628b727d382.1465996447.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test WARNING on tip/irq/core]
[also build test WARNING on v4.7-rc3 next-20160615]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Paolo-Abeni/genirq-threadable-IRQ-support/20160615-214836
reproduce: make htmldocs

All warnings (new ones prefixed by >>):

>> kernel/irq/manage.c:1681: warning: No description found for parameter 'notifier'
>> kernel/irq/manage.c:1681: warning: Excess function parameter 'mode_notifier' description in 'irq_set_mode_notifier'
   kernel/irq/handle.c:1: warning: no structured comments found
--
   lib/crc32.c:148: warning: No description found for parameter 'tab)[256]'
   lib/crc32.c:148: warning: Excess function parameter 'tab' description in 'crc32_le_generic'
   lib/crc32.c:293: warning: No description found for parameter 'tab)[256]'
   lib/crc32.c:293: warning: Excess function parameter 'tab' description in 'crc32_be_generic'
   lib/crc32.c:1: warning: no structured comments found
   mm/memory.c:2881: warning: No description found for parameter 'old'
>> kernel/irq/manage.c:1681: warning: No description found for parameter 'notifier'
>> kernel/irq/manage.c:1681: warning: Excess function parameter 'mode_notifier' description in 'irq_set_mode_notifier'

vim +/notifier +1681 kernel/irq/manage.c

  1665	/**
  1666	 *	irq_set_mode_notifier - register a mode change notifier
  1667	 *	@irq: Interrupt line
  1668	 *	@dev_id: The cookie used to identify the irq handler and passed back
  1669	 *		 to the notifier
  1670	 *	@mode_notifier: The callback to be registered
  1671	 *
  1672	 *	This call registers a callback to notify the device about irq mode
  1673	 *	change (threaded/normal mode). Mode change are triggered writing on
  1674	 *	the 'threaded' procfs entry.
  1675	 *	When running in threaded mode the irq thread task struct will be passed
  1676	 *	to the notifer, or NULL elsewhere. It's up to the device update its
  1677	 *	internal state accordingly
  1678	 */
  1679	int irq_set_mode_notifier(unsigned int irq, void *dev_id,
  1680				  mode_notifier_t notifier)
> 1681	{
  1682		struct irq_desc *desc = irq_to_desc(irq);
  1683		struct irqaction *action;
  1684		unsigned long flags;
  1685		int ret = -EINVAL;
  1686	
  1687		if (!desc)
  1688			return ret;
  1689	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--envbJBWh7q8WU6mo
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--envbJBWh7q8WU6mo--
