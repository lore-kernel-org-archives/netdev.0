From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Tue, 25 Jan 2005 19:32:07 +0000
Message-ID: <20050125193207.B30094@flint.arm.linux.org.uk>
References: <20050121161959.GO3922@fi.muni.cz> <1106360639.15804.1.camel@boxen> <20050123091154.GC16648@suse.de> <20050123011918.295db8e8.akpm@osdl.org> <20050123095608.GD16648@suse.de> <20050123023248.263daca9.akpm@osdl.org> <20050123200315.A25351@flint.arm.linux.org.uk> <20050124114853.A16971@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262085AbVAYTcv@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Jens Axboe <axboe@suse.de>,
	alexn@dsv.su.se, kas@fi.muni.cz, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050124114853.A16971@flint.arm.linux.org.uk>; from rmk+lkml@arm.linux.org.uk on Mon, Jan 24, 2005 at 11:48:53AM +0000
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 24, 2005 at 11:48:53AM +0000, Russell King wrote:
> On Sun, Jan 23, 2005 at 08:03:15PM +0000, Russell King wrote:
> > I think I may be seeing something odd here, maybe a possible memory leak.
> > The only problem I have is wondering whether I'm actually comparing like
> > with like.  Maybe some networking people can provide a hint?
> > 
> > Below is gathered from 2.6.11-rc1.
> > 
> > bash-2.05a# cat /proc/net/rt_cache | wc -l; grep ip_dst /proc/slabinfo
> > 24
> > ip_dst_cache         669    885    256   15    1
> > 
> > I'm fairly positive when I rebooted the machine a couple of days ago,
> > ip_dst_cache was significantly smaller for the same number of lines in
> > /proc/net/rt_cache.
> 
> FYI, today it looks like this:
> 
> bash-2.05a# cat /proc/net/rt_cache | wc -l; grep ip_dst /proc/slabinfo
> 26
> ip_dst_cache         820   1065    256   15    1 
> 
> So the dst cache seems to have grown by 151 in 16 hours...  I'll continue
> monitoring and providing updates.

Tonights update:
50
ip_dst_cache        1024   1245    256   15    1

As you can see, the dst cache is consistently growing by about 200
entries per day.  Given this, I predict that the box will fall over
due to "dst cache overflow" in roughly 35 days.

kernel network configuration:

CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_FWMARK=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_SYN_COOKIES=y
CONFIG_IPV6=y
CONFIG_NETFILTER=y
CONFIG_IP_NF_CONNTRACK=y
CONFIG_IP_NF_CONNTRACK_MARK=y
CONFIG_IP_NF_FTP=y
CONFIG_IP_NF_IRC=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_LIMIT=y
CONFIG_IP_NF_MATCH_IPRANGE=y
CONFIG_IP_NF_MATCH_MAC=m
CONFIG_IP_NF_MATCH_PKTTYPE=m
CONFIG_IP_NF_MATCH_MARK=y
CONFIG_IP_NF_MATCH_MULTIPORT=m
CONFIG_IP_NF_MATCH_TOS=m
CONFIG_IP_NF_MATCH_RECENT=y
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_DSCP=m
CONFIG_IP_NF_MATCH_AH_ESP=m
CONFIG_IP_NF_MATCH_LENGTH=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_MATCH_TCPMSS=m
CONFIG_IP_NF_MATCH_HELPER=y
CONFIG_IP_NF_MATCH_STATE=y
CONFIG_IP_NF_MATCH_CONNTRACK=y
CONFIG_IP_NF_MATCH_ADDRTYPE=m
CONFIG_IP_NF_MATCH_REALM=m
CONFIG_IP_NF_MATCH_CONNMARK=m
CONFIG_IP_NF_MATCH_HASHLIMIT=m
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_LOG=m
CONFIG_IP_NF_TARGET_TCPMSS=m
CONFIG_IP_NF_NAT=y
CONFIG_IP_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_IP_NF_TARGET_REDIRECT=y
CONFIG_IP_NF_TARGET_NETMAP=y
CONFIG_IP_NF_TARGET_SAME=y
CONFIG_IP_NF_NAT_IRC=y
CONFIG_IP_NF_NAT_FTP=y
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_TOS=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_DSCP=m
CONFIG_IP_NF_TARGET_MARK=y
CONFIG_IP_NF_TARGET_CLASSIFY=m
CONFIG_IP_NF_TARGET_CONNMARK=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_LIMIT=y
CONFIG_IP6_NF_MATCH_MAC=y
CONFIG_IP6_NF_MATCH_RT=y
CONFIG_IP6_NF_MATCH_OPTS=y
CONFIG_IP6_NF_MATCH_FRAG=y
CONFIG_IP6_NF_MATCH_HL=y
CONFIG_IP6_NF_MATCH_MULTIPORT=y
CONFIG_IP6_NF_MATCH_MARK=y
CONFIG_IP6_NF_MATCH_AHESP=y
CONFIG_IP6_NF_MATCH_LENGTH=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_TARGET_MARK=y


-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
