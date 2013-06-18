From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: poll/select low latency socket support
Date: Tue, 18 Jun 2013 07:35:48 -0700
Message-ID: <1371566148.3252.255.camel@edumazet-glaptop>
References: <20130618085759.10941.15811.stgit@ladj378.jer.intel.com>
	  <20130618085810.10941.55039.stgit@ladj378.jer.intel.com>
	 <1371551139.3252.249.camel@edumazet-glaptop>
	 <51C05FC1.4000201@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Avner Ben Hanoch <avnerb@mellanox.com>,
	Or Kehati <ork@mellanox.com>, sockperf-dev@googlegroups.com,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C05FC1.4000201@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-06-18 at 16:25 +0300, Eliezer Tamir wrote:

> One other thing,
> sock_poll() will only ll_poll if the flag was set _and_ the socket has a
> none-zero value in sk->sk_ll_usec so you still only poll on sockets
> that were enabled for LLS, not on every socket.

But sockets are default enabled for LLS.

sock_init_data()
{
	...
	sk->sk_ll_usec      =   sysctl_net_ll_poll; 
	...
}
