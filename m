From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] bridge/netfilter: avoid unused label warning
Date: Mon, 12 Oct 2015 17:48:20 +0200
Message-ID: <20151012154820.GA23092@salvia>
References: <5180534.sSnu9AX8xS@wuerfel>
 <561666B9.8070802@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, netfilter-devel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <561666B9.8070802@cumulusnetworks.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 08, 2015 at 02:51:05PM +0200, Nikolay Aleksandrov wrote:
> On 10/08/2015 02:30 PM, Arnd Bergmann wrote:
> > With the ARM mini2440_defconfig, the bridge netfilter code gets
> > built with both CONFIG_NF_DEFRAG_IPV4 and CONFIG_NF_DEFRAG_IPV6
> > disabled, which leads to a harmless gcc warning:
> > 
> > net/bridge/br_netfilter_hooks.c: In function 'br_nf_dev_queue_xmit':
> > net/bridge/br_netfilter_hooks.c:792:2: warning: label 'drop' defined but not used [-Wunused-label]
> > 
> > This gets rid of the warning by cleaning up the code to avoid
> > the respective #ifdefs causing this problem, and replacing them
> > with if(IS_ENABLED()) checks. I have verified that the resulting
> > object code is unchanged, and an additional advantage is that
> > we now get compile coverage of the unused functions in more
> > configurations.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: dd302b59bde0 ("netfilter: bridge: don't leak skb in error paths")
> > ---
> > Version 2:
> > 
> > Rebased to git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
> > 
> 
> Looks good to me,
> 
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Nice that we got rid of that many ifdefs. Thanks!

BTW, just for the record in case someone search for this on the
Internet: I have renamed the subject to "netfilter: bridge: avoid
unused label warning" for consistency with other existing subject
lines in the repo.
