From: dann frazier <dannf@dannf.org>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Tue, 5 Apr 2011 15:08:33 -0600
Message-ID: <20110405210833.GA22667@dannf.org>
References: <20110404194856.GA3720@dannf.org>
 <4D9A23BC.4010505@trash.net>
 <1301949477.3021.55.camel@edumazet-laptop>
 <1301957293.3021.191.camel@edumazet-laptop>
 <1301984679.3021.655.camel@edumazet-laptop>
 <1301987879.3021.714.camel@edumazet-laptop>
 <4D9AF1C6.6050304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D9AF1C6.6050304@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2011 at 12:41:10PM +0200, Patrick McHardy wrote:
> On 05.04.2011 09:17, Eric Dumazet wrote:
> > Here is the cumulative patch
> 
> 
> Thanks Eric. I'll wait for confirmation from Dann before applying
> this.

Yes, thanks Eric! I'll test as soon as I can take my laptop down..

     -dann
> 
> > [PATCH] netfilter: fix ebtables
> > 
> > commit 255d0dc34068a976 (netfilter: x_table: speedup compat operations)
> > made ebtables not working anymore.
> > 
> > 1) xt_compat_calc_jump() is not an exact match lookup, and 
> > 2) compat_table_info() has a typo in xt_compat_init_offsets() call
> > 3) compat_do_replace() misses a xt_compat_init_offsets() call
> > 
> > Reported-by: dann frazier <dannf@dannf.org>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  net/bridge/netfilter/ebtables.c |    3 ++-
> >  net/netfilter/x_tables.c        |    3 +++
> >  2 files changed, 5 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> > index 893669c..c66aa80 100644
> > --- a/net/bridge/netfilter/ebtables.c
> > +++ b/net/bridge/netfilter/ebtables.c
> > @@ -1766,7 +1766,7 @@ static int compat_table_info(const struct ebt_table_info *info,
> >  
> >  	newinfo->entries_size = size;
> >  
> > -	xt_compat_init_offsets(AF_INET, info->nentries);
> > +	xt_compat_init_offsets(NFPROTO_BRIDGE, info->nentries /* + 4*/);
> 
> I assume the /* + 4 */ is left over from debugging, I'll remove it
> before applying.
> 
