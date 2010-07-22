From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC 1/1] netfilter: xtables: inclusion of xt_condition
Date: Thu, 22 Jul 2010 22:19:40 +0300
Message-ID: <20100722191940.GA10029@x200>
References: <1279807758-6876-1-git-send-email-luciano.coelho@nokia.com>
 <1279807758-6876-2-git-send-email-luciano.coelho@nokia.com>
 <alpine.LSU.2.01.1007221621270.1619@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luciano Coelho <luciano.coelho@nokia.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, sameo@linux.intel.com
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.01.1007221621270.1619@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 22, 2010 at 04:44:35PM +0200, Jan Engelhardt wrote:
> 
> On Thursday 2010-07-22 16:09, Luciano Coelho wrote:
> >+static int condition_mt_check(const struct xt_mtchk_param *par)
> >+{
> >+	struct xt_condition_mtinfo *info = par->matchinfo;
> >+	struct condition_variable *var;
> >+	struct condition_net *cond_net =
> >+		condition_pernet(current->nsproxy->net_ns);
> 
> Cc'ing Alexey who has done the netns support.
> 
> Alexey, you added par->net, but given Luciano just did it with 
> current->nsproxy->net_ns, do we really need par->net?

In ->check, maybe, we can get away with current->nsproxy->net_ns.

But definitely not in ->destroy(), because destruction can happen
when _no_ task is in netns, so current->nsproxy->net_ns is 100% bogus.

Steps to reproduce:
	iptables -A ...
	exit

->destroy hook gets netns from par->net, ->checkentry does the same
for symmetry and less confusion.
