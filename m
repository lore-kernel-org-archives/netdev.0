From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: tcp_bic (was Re: 2.6.12-rc6-mm1 OOPS in tcp_push_one()
Date: Thu, 9 Jun 2005 09:15:28 -0700
Message-ID: <20050609091528.1bc1940e@unknown-215.office.pdx.osdl.net>
References: <200506090423.j594NWts004829@turing-police.cc.vt.edu>
	<20050608.225817.112619139.davem@davemloft.net>
	<200506091523.j59FNmsr008443@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200506091523.j59FNmsr008443@turing-police.cc.vt.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This was all changed in 2.6.12-rc6-tcp1 which is the next version going into
-mm. The default congestion control will be the last one registered (LIFO);
so if you built everything as modules. the default will be reno. If you
build with the default's from Kconfig, bic will be builtin (not a module)
and it will end up the default.

If you really want a particular default value then you will need
to set it with a sysctl.  If you use a sysctl, the module will be autoloaded
if needed and you will get the expected protocol. If you ask for an
unknown congestion method, then the sysctl attempt will fail.

If you remove a tcp congestion control module, then you will get the next
available one. Since reno can not be built as a module, and can not be
deleted, it will always be available.
