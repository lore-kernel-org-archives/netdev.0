From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netfilter: ctnetlink: add more #ifdef around unused code
Date: Mon, 18 Apr 2016 20:33:15 +0200
Message-ID: <4187960.DvZepuNvUx@wuerfel>
References: <1460837916-1241019-1-git-send-email-arnd@arndb.de> <20160418181659.GA2427@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418181659.GA2427@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 18 April 2016 20:16:59 Pablo Neira Ayuso wrote:
> On Sat, Apr 16, 2016 at 10:17:43PM +0200, Arnd Bergmann wrote:
> > A recent patch removed many 'inline' annotations for static
> > functions in this file, which has caused warnings for functions
> > that are not used in a given configuration, in particular when
> > CONFIG_NF_CONNTRACK_EVENTS is disabled:
> > 
> > nf_conntrack_netlink.c:572:15: 'ctnetlink_timestamp_size' defined but not used
> > nf_conntrack_netlink.c:546:15: 'ctnetlink_acct_size' defined but not used
> > nf_conntrack_netlink.c:339:12: 'ctnetlink_label_size' defined but not used
> 
> Arnd, thanks for the fix.
> 
> I'm planning to push this though:
> 
> http://patchwork.ozlabs.org/patch/610820/
> 
> This is restoring the inlines for the size calculation functions, but
> I think that's ok. They are rather small and they're called from the
> event notification path (ie. packet path), so the compiler just place
> them out of the way when not needed and we calm down the gcc warning.

Looks good. I'll put this in my randconfig builder to replace my own
patch and will let you know if you missed something.

	Arnd
