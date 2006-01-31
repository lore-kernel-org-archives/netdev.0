From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip_conntrack related slab error (Re: Fw: Re: 2.6.16-rc1-mm3)
Date: Tue, 31 Jan 2006 13:50:25 +0100
Message-ID: <43DF5D11.2040703@trash.net>
References: <20060130221429.5f12d947.akpm@osdl.org> <20060131092447.GL4603@sunbeam.de.gnumonks.org> <43DF36FD.70305@reub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750799AbWAaMua@vger.kernel.org>
To: Reuben Farrelly <reuben-lkml@reub.net>
In-Reply-To: <43DF36FD.70305@reub.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reuben Farrelly wrote:
> tornado.reub.net login: BUG: unable to handle kernel paging request at
> virtual address 00200200

This means ct->nat.info.bysource was already removed from the list,
which can only happen if the conntrack entry is destroyed twice.

I can't find how this could have happened, please enable
CONFIG_NETFILTER_DEBUG, the DPRINTK defines in
ip_conntrack_{standalone,core,netlink}.c and ip_nat_{core,standalone}.c
and logging of invalid packets ("echo 255 >
/proc/sys/net/ipv4/netfilter/ip_conntrack_log_invalid"). I hope this
will give some clues ..
