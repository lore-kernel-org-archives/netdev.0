From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH next] netlink: prevent deadlock in ctrl_dumpfamily()
Date: Tue, 20 Aug 2013 22:31:17 +0300
Message-ID: <20130820193117.GA2239@swordfish>
References: <20130820135033.GA2315@swordfish.minsk.epam.com>
 <1DC40B07CD6EC041A66726C271A73AE61AA6F1BC@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Berg, Johannes" <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1DC40B07CD6EC041A66726C271A73AE61AA6F1BC@IRSMSX102.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (08/20/13 14:03), Berg, Johannes wrote:
> > +	if (need_locking) {
> > +		/* genl_mutex could be already locked in genl_rcv_msg() */
> > +		rt = genl_family_find_byid(cb->nlh->nlmsg_type);
> > +		need_locking = need_locking && rt->parallel_ops;
> > +	}
> 
> This is equivalent to reverting the patch because parallel_ops will be false for the genl family. :-)
>

sorry, didn't notice that there is already a thread on lkml regarding
this issue. will follow that discussion. the reason was that I see an
actual deadlock on my machine during certain network activities, but
lockdep is silent.

thanks,
	-ss

> johannes
> -- 
> 
> Intel GmbH
> Dornacher Strasse 1
> 85622 Feldkirchen/Muenchen, Deutschland
> Sitz der Gesellschaft: Feldkirchen bei Muenchen
> Geschaeftsfuehrer: Christian Lamprechter, Hannes Schwaderer, Douglas Lusk
> Registergericht: Muenchen HRB 47456
> Ust.-IdNr./VAT Registration No.: DE129385895
> Citibank Frankfurt a.M. (BLZ 502 109 00) 600119052
> 
