From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net ax25: Reorder ax25_exit to remove races.
Date: Thu, 19 Apr 2012 15:38:05 -0400 (EDT)
Message-ID: <20120419.153805.1416561328432806364.davem@davemloft.net>
References: <m1hawgjws4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	linux-hams@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <m1hawgjws4.fsf@fess.ebiederm.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 18 Apr 2012 19:11:23 -0700

> While reviewing the sysctl code in ax25 I spotted races in ax25_exit
> where it is possible to receive notifications and packets after already
> freeing up some of the data structures needed to process those
> notifications and updates.
> 
> Call unregister_netdevice_notifier early so that the rest of the cleanup
> code does not need to deal with network devices.  This takes advantage
> of my recent enhancement to unregister_netdevice_notifier to send
> unregister notifications of all network devices that are current
> registered.
> 
> Move the unregistration for packet types, socket types and protocol
> types before we cleanup any of the ax25 data structures to remove the
> possibilities of other races.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks a lot Eric.
