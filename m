From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Wed, 28 Sep 2005 02:25:16 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0509280219110.25500@filer.marasystems.com>
References: <432EF0C5.5090908@cosmosbay.com> <200509221503.21650.ak@suse.de>
	<20050923170911.GN731@sunbeam.de.gnumonks.org>
	<200509271823.19365.ak@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Harald Welte <laforge@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200509271823.19365.ak@suse.de>
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

On Tue, 27 Sep 2005, Andi Kleen wrote:

> That could be special cased and done lockless, with the counting
> done per CPU.

It's also not very hard for iptables when verifying the table to conclude 
that there really isn't any "real" rules for a certain hook and then 
delete that hook registration (only policy ACCEPT rule found). Allowing 
you to have as many ip tables modules you like in the kernel, but only 
using the hooks where you have rules.  Drawback is that you loose the 
packet counters on the policy.

Exception: iptable_nat. Needs the hooks for other purposes as well, not 
just the iptable so here the hooks can not be deactivated when there is no 
rules.

Regards
Henrik
