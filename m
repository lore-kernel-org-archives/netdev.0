From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [net v6 1/8] i40e: main driver core
Date: Sat, 7 Sep 2013 19:27:53 +0000
Message-ID: <1378582073.2509.18.camel@jbrandeb-mobl.amr.corp.intel.com>
References: <1378510875-10704-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378510875-10704-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<522AD28B.5050507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <522AD28B.5050507@redhat.com>
Content-Language: en-US
Content-ID: <D2FF772FC3110C4EAA315A3150DBD2BA@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, 2013-09-07 at 09:15 +0200, Daniel Borkmann wrote:

> Thanks for including SCTP! ;-)

:-)


> Here as well, I40E_ERR_NO_MEMORY vs -ENOMEM.
> 

okay we will audit those and fix them.

> 
> Nitpick: why s32 in the signature? There are a lot of such places, just int would have
> been fine probably.
> 

agreed.

> 			}
> > +			if (pf->lan_veb == I40E_NO_VEB) {
> > +				v = i40e_veb_mem_alloc(pf);
> > +				if (v < 0)
> > +					break;
> 
> Nitpick: I'd expect from *alloc() functions to return NULL, but fair enough.

I will take a look at what we can do about these.


> > +	aq_buf = kzalloc(I40E_AQ_LARGE_BUF, GFP_KERNEL);
> > +	if (!aq_buf)
> > +		return -ENOMEM;
> 
> More of such examples ... ;-) I40E_ERR_BAD_PTR vs. -ENOMEM on a s32 instead of int.

right

> > +	} else if (pf->flags & I40E_FLAG_RSS_ENABLED	  &&
> > +		   !(pf->flags & I40E_FLAG_FDIR_ENABLED)  &&
> > +		   !(pf->flags & I40E_FLAG_DCB_ENABLED)) {
> > +
> > +		SET_RSS_SIZE;
> 
> Can't these macros be done in a small inline function instead?

I'll take a look, as well for all instances of this.

Thanks again,
 Jesse
------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58041391&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
