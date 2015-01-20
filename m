From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Tue, 20 Jan 2015 15:35:56 +0000
Message-ID: <20150120153556.GJ20315@casper.infradead.org>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
 <20150120145551.GH20315@casper.infradead.org>
 <20150120152149.GA3012@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150120152149.GA3012@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/20/15 at 03:21pm, Patrick McHardy wrote:
> I think its preferrable to make the need to handle NETLINK_F_DUMP_INTR
> as noticable as possible and not hide it. Silent failure is the worst
> kind of failure.

I agree to that. The point here is to avoid unnecessary use of
NETLINK_F_DUMP_INTR if all entries fit into a single message buffer.
 
> Yeah. The point could be made that this is a regression though. We didn't
> require userspace to deal with interruptions before, and the behaviour
> was well defined and acceptable for most cases, its not anymore.
> 
> So I think it should be handled by the kernel, without changes to
> userspace.

nl_table_lock was released between individual messages just like
ht->mutex is released with this change.

What changed is that inserts and removal can now occur *while* the
message is being constructed whereas previously they could only
occur between message construction periods. In either case, the dump
would end up missing entries or showing duplicates.
