From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC 1/1] netfilter: xtables: inclusion of xt_condition
Date: Thu, 22 Jul 2010 22:30:07 +0300
Message-ID: <1279827007.1630.15.camel@powerslave>
References: <1279807758-6876-1-git-send-email-luciano.coelho@nokia.com>
	 <1279807758-6876-2-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1007221621270.1619@obet.zrqbmnf.qr>
	 <20100722191940.GA10029@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: ext Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100722191940.GA10029@x200>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-07-22 at 21:19 +0200, ext Alexey Dobriyan wrote:
> On Thu, Jul 22, 2010 at 04:44:35PM +0200, Jan Engelhardt wrote:
> > 
> > On Thursday 2010-07-22 16:09, Luciano Coelho wrote:
> > >+static int condition_mt_check(const struct xt_mtchk_param *par)
> > >+{
> > >+	struct xt_condition_mtinfo *info = par->matchinfo;
> > >+	struct condition_variable *var;
> > >+	struct condition_net *cond_net =
> > >+		condition_pernet(current->nsproxy->net_ns);
> > 
> > Cc'ing Alexey who has done the netns support.
> > 
> > Alexey, you added par->net, but given Luciano just did it with 
> > current->nsproxy->net_ns, do we really need par->net?
> 
> In ->check, maybe, we can get away with current->nsproxy->net_ns.
> 
> But definitely not in ->destroy(), because destruction can happen
> when _no_ task is in netns, so current->nsproxy->net_ns is 100% bogus.
> 
> Steps to reproduce:
> 	iptables -A ...
> 	exit
> 
> ->destroy hook gets netns from par->net, ->checkentry does the same
> for symmetry and less confusion.

Very good point.  I guess that when Patrick suggested using
current->nsproxy->net_ns, he meant only for the module_params part.
I'll be removing that anyway.  And I'll change the code to use par->net
instead of current->nsproxy->net_ns to avoid the problem in _destroy.

Thanks for your comments!

I must admit that I was a bit insecure about this code.  That's why I
sent a RFC early enough. ;)


-- 
Cheers,
Luca.

