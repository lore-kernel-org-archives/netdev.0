From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipt_recent: fix race between recent_mt_destroy and proc
 manipulations
Date: Wed, 30 Jul 2008 12:52:53 +0200
Message-ID: <48904805.7050009@trash.net>
References: <4887A2A6.1010704@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4887A2A6.1010704@openvz.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> The thing is that recent_mt_destroy first flushes the entries
> from table with the recent_table_flush and only *after* this
> removes the proc file, corresponding to that table.
> 
> Thus, if we manage to write to this file the '+XXX' command we
> will leak some entries. If we manage to write there a 'clean'
> command we'll race in two recent_table_flush flows, since the
> recent_mt_destroy calls this outside the recent_lock.
> 
> The proper solution as I see it is to remove the proc file first
> and then go on with flushing the table. This flushing becomes
> safe w/o the lock, since the table is already inaccessible from
> the outside.

Applied, thanks.
