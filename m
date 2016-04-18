From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ctnetlink: add more #ifdef around unused code
Date: Mon, 18 Apr 2016 20:16:59 +0200
Message-ID: <20160418181659.GA2427@salvia>
References: <1460837916-1241019-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460837916-1241019-1-git-send-email-arnd@arndb.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 16, 2016 at 10:17:43PM +0200, Arnd Bergmann wrote:
> A recent patch removed many 'inline' annotations for static
> functions in this file, which has caused warnings for functions
> that are not used in a given configuration, in particular when
> CONFIG_NF_CONNTRACK_EVENTS is disabled:
> 
> nf_conntrack_netlink.c:572:15: 'ctnetlink_timestamp_size' defined but not used
> nf_conntrack_netlink.c:546:15: 'ctnetlink_acct_size' defined but not used
> nf_conntrack_netlink.c:339:12: 'ctnetlink_label_size' defined but not used

Arnd, thanks for the fix.

I'm planning to push this though:

http://patchwork.ozlabs.org/patch/610820/

This is restoring the inlines for the size calculation functions, but
I think that's ok. They are rather small and they're called from the
event notification path (ie. packet path), so the compiler just place
them out of the way when not needed and we calm down the gcc warning.

Thanks!
