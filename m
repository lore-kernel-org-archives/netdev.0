From: Olaf Kirch <okir@suse.de>
Subject: Re: (usagi-users 03180) Re: netfilter6: ICMPv6 type 143 doesn't
	match
Date: Mon, 10 Jan 2005 14:17:09 +0100
Message-ID: <20050110131709.GB16911@suse.de>
References: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
	<200412270417.iBR4HZRG021429@toshiba.co.jp>
	<20041227.100205.102356251.yoshfuji@linux-ipv6.org>
	<EA4274721EC980393BB13B5E@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com,
	yasuyuki.kozakai@toshiba.co.jp,
	netfilter-devel@lists.netfilter.org, laforge@gnumonks.org, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Peter Bieringer <pb@bieringer.de>
Content-Disposition: inline
In-Reply-To: <EA4274721EC980393BB13B5E@worker.muc.bieringer.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 08, 2005 at 12:45:14PM +0100, Peter Bieringer wrote:
> -               ptr = IPV6_HDR_LEN;
> +               ptr = ((u8*)skb->nh.raw - skb->data) + IPV6_HDR_LEN;
[...]
> But it won't help :-((

The following works for me on 2.6.8:

		ptr = ((char *) ipv6 - (char *) skb->data) + IPV6_HDR_LEN;

Older 2.6 kernels also do not call ipv6_skip_exthdr() in icmp6_match();
more recent kernels fix this.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"
