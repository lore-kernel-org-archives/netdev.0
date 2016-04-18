From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ctnetlink: add more #ifdef around unused code
Date: Mon, 18 Apr 2016 22:14:57 +0200
Message-ID: <20160418201457.GA19681@salvia>
References: <1460837916-1241019-1-git-send-email-arnd@arndb.de>
 <4187960.DvZepuNvUx@wuerfel>
 <20160418184336.GA16586@salvia>
 <3838598.xdNY1BW5d9@wuerfel>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3838598.xdNY1BW5d9@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2016 at 10:04:43PM +0200, Arnd Bergmann wrote:
> On Monday 18 April 2016 20:43:36 Pablo Neira Ayuso wrote:
> > On Mon, Apr 18, 2016 at 08:33:15PM +0200, Arnd Bergmann wrote:
> > > On Monday 18 April 2016 20:16:59 Pablo Neira Ayuso wrote:
> > > > On Sat, Apr 16, 2016 at 10:17:43PM +0200, Arnd Bergmann wrote:
> > > > > A recent patch removed many 'inline' annotations for static
> > > > > functions in this file, which has caused warnings for functions
> > > > > that are not used in a given configuration, in particular when
> > > > > CONFIG_NF_CONNTRACK_EVENTS is disabled:
> > > > > 
> > > > > nf_conntrack_netlink.c:572:15: 'ctnetlink_timestamp_size' defined but not used
> > > > > nf_conntrack_netlink.c:546:15: 'ctnetlink_acct_size' defined but not used
> > > > > nf_conntrack_netlink.c:339:12: 'ctnetlink_label_size' defined but not used
> > > > 
> > > > Arnd, thanks for the fix.
> > > > 
> > > > I'm planning to push this though:
> > > > 
> > > > http://patchwork.ozlabs.org/patch/610820/
> > > > 
> > > > This is restoring the inlines for the size calculation functions, but
> > > > I think that's ok. They are rather small and they're called from the
> > > > event notification path (ie. packet path), so the compiler just place
> > > > them out of the way when not needed and we calm down the gcc warning.
> > > 
> > > Looks good. I'll put this in my randconfig builder to replace my own
> > > patch and will let you know if you missed something.
> > 
> > Thanks, will wait for your ack then.
> 
> 100 clean randconfig builds later, looks good to me.
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Thanks! I have applied this to nf-next.
