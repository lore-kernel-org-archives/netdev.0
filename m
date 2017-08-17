From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] Adding-Agile-SD-TCP-module-and-modifying-Kconfig-and-makefile
 (fwd)
Date: Thu, 17 Aug 2017 11:23:49 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1708171121310.3748@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Mohamed A . Alrshah" <mohamed.a.alrshah@ieee.org>,
        Mohamed Othman <mothman@upm.edu.my>,
        Borhanuddin Ali <borhan@upm.edu.my>,
        Zurina Hanapi <zurinamh@upm.edu.my>, kbuild-all@01.org
To: mohamedalrshah <mohamed.a.alrshah@ieee.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is intentional that the code on lines 122 and 124 is the same?

julia

---------- Forwarded message ----------
Date: Thu, 17 Aug 2017 09:18:50 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH]
    Adding-Agile-SD-TCP-module-and-modifying-Kconfig-and-makefile

Hi mohamedalrshah,

[auto build test WARNING on net/master]
[also build test WARNING on v4.13-rc5 next-20170816]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/mohamedalrshah/Adding-Agile-SD-TCP-module-and-modifying-Kconfig-and-makefile/20170817-055643
:::::: branch date: 3 hours ago
:::::: commit date: 3 hours ago

>> net/ipv4/tcp_agilesd.c:121:1-3: WARNING: possible condition with no effect (if == else)

# https://github.com/0day-ci/linux/commit/839e8cb5e5f068e0310442909f9a89753a218c59
git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 839e8cb5e5f068e0310442909f9a89753a218c59
vim +121 net/ipv4/tcp_agilesd.c

839e8cb5 mohamedalrshah 2017-08-15  111
839e8cb5 mohamedalrshah 2017-08-15  112  /* This function is called when the TCP flow detects a loss.
839e8cb5 mohamedalrshah 2017-08-15  113   * It returns the slow start threshold of a flow, after a packet loss is detected. */
839e8cb5 mohamedalrshah 2017-08-15  114  static u32 agilesdtcp_recalc_ssthresh(struct sock *sk)
839e8cb5 mohamedalrshah 2017-08-15  115  {
839e8cb5 mohamedalrshah 2017-08-15  116  	const struct tcp_sock *tp = tcp_sk(sk);
839e8cb5 mohamedalrshah 2017-08-15  117  	struct agilesdtcp *ca = inet_csk_ca(sk);
839e8cb5 mohamedalrshah 2017-08-15  118
839e8cb5 mohamedalrshah 2017-08-15  119  	ca->loss_cwnd = tp->snd_cwnd;
839e8cb5 mohamedalrshah 2017-08-15  120
839e8cb5 mohamedalrshah 2017-08-15 @121  	if (ca->agilesd_tcp_status == CA)
839e8cb5 mohamedalrshah 2017-08-15  122  		ca->degraded_loss_cwnd = max((tp->snd_cwnd * beta) / SCALE, 2U);
839e8cb5 mohamedalrshah 2017-08-15  123  	else
839e8cb5 mohamedalrshah 2017-08-15  124  		ca->degraded_loss_cwnd = max((tp->snd_cwnd * beta) / SCALE, 2U);
839e8cb5 mohamedalrshah 2017-08-15  125
839e8cb5 mohamedalrshah 2017-08-15  126  	ca->frac_tracer = 0;
839e8cb5 mohamedalrshah 2017-08-15  127
839e8cb5 mohamedalrshah 2017-08-15  128  	return ca->degraded_loss_cwnd;
839e8cb5 mohamedalrshah 2017-08-15  129  }
839e8cb5 mohamedalrshah 2017-08-15  130

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
