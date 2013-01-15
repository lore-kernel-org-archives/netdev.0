From: Cong Ding <dinggnu@gmail.com>
Subject: Re: [PATCH] net: netfilter/xt_CT.c: fix uninitialized variable
Date: Tue, 15 Jan 2013 20:16:14 +0100
Message-ID: <20130115191613.GD7211@gmail.com>
References: <1358276314-9536-1-git-send-email-dinggnu@gmail.com>
 <1358276792.1991.121.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358276792.1991.121.camel@ppwaskie-mobl2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 15, 2013 at 07:06:51PM +0000, Waskiewicz Jr, Peter P wrote:
> On Tue, 2013-01-15 at 19:58 +0100, Cong Ding wrote:
> > If CONFIG_NF_CONNTRACK_ZONES is not defined, the variable ret might be
> > uninitialized when it goes to err1 through line 125 and 263 respectively.
> > So I change these goto err1 to return -EINVAL directly.
> > 
> > Signed-off-by: Cong Ding <dinggnu@gmail.com>
> > ---
> >  net/netfilter/xt_CT.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
> > index 2a08430..941f600 100644
> > --- a/net/netfilter/xt_CT.c
> > +++ b/net/netfilter/xt_CT.c
> > @@ -122,7 +122,7 @@ static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
> >  
> >  #ifndef CONFIG_NF_CONNTRACK_ZONES
> >  	if (info->zone)
> > -		goto err1;
> > +		return -EINVAL;
> >  #endif
> >  
> >  	ret = nf_ct_l3proto_try_module_get(par->family);
> > @@ -260,7 +260,7 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
> >  
> >  #ifndef CONFIG_NF_CONNTRACK_ZONES
> >  	if (info->zone)
> > -		goto err1;
> > +		return -EINVAL;
> >  #endif
> 
> In dropping both goto's, you left the err1 label unused.  Wouldn't just
> initializing ret to -EINVAL be easier and cleaner?  Then you wouldn't be
> messing with the flow of the function.
The label err1 are also used in line 130 and 298. I change it to "return
-EINVAL" rather than initialize ret to -EINVAL is to keep it the same as line
115 and 253.  Otherwise, we should change line 115 and 253 to be goto err1,
too?
- cong
