From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/2] net: remove NET_LL_RX_POLL config menue
Date: Wed, 12 Jun 2013 19:01:03 -0700
Message-ID: <20130612190103.1545e310@nehalam.linuxnetplumber.net>
References: <20130611142415.17879.75569.stgit@ladj378.jer.intel.com>
	<20130611142428.17879.33582.stgit@ladj378.jer.intel.com>
	<20130612.151205.1822920389019274346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eliezer.tamir@linux.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	donald.c.skidmore@intel.com, e1000-devel@lists.sourceforge.net,
	willemb@google.com, erdnetdev@gmail.com, bhutchings@solarflare.com,
	andi@firstfloor.org, hpa@zytor.com, eilong@broadcom.com,
	or.gerlitz@gmail.com, amirv@mellanox.com, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130612.151205.1822920389019274346.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Jun 2013 15:12:05 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Tue, 11 Jun 2013 17:24:28 +0300
> 
> >  	depends on X86_TSC
> 
> Wait a second, I didn't notice this before.  There needs to be a better
> way to test for the accuracy you need, or if the issue is lack of a proper
> API for cycle counter reading, fix that rather than add ugly arch
> specific dependencies to generic networking code.

This should be sched_clock(), rather than direct TSC access.
Also any code using TSC or sched_clock has to be carefully audited to deal with
clocks running at different rates on different CPU's. Basically value is only
meaning full on same CPU.
