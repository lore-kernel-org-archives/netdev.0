From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Re: [PATCHv4 10/11] drop_monitor: Use *_dec_not_zero instead of
 *_add_unless
Date: Wed, 27 Jul 2011 10:25:22 -0400
Message-ID: <20110727142521.GB19001@hmsreliant.think-freely.org>
References: <1311760070-21532-1-git-send-email-sven@narfation.org>
 <1311760070-21532-10-git-send-email-sven@narfation.org>
 <20110727105907.GA19001@hmsreliant.think-freely.org>
 <2127465.xrCKehbL3A@sven-laptop.home.narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sven Eckelmann <sven@narfation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2127465.xrCKehbL3A@sven-laptop.home.narfation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2011 at 01:52:50PM +0200, Sven Eckelmann wrote:
> On Wednesday 27 July 2011 06:59:07 Neil Horman wrote:
> > On Wed, Jul 27, 2011 at 11:47:49AM +0200, Sven Eckelmann wrote:
> > > atomic_dec_not_zero is defined for each architecture through
> > > <linux/atomic.h> to provide the functionality of
> > > atomic_add_unless(x, -1, 0).
> > > 
> > > Signed-off-by: Sven Eckelmann <sven@narfation.org>
> > > Cc: Neil Horman <nhorman@tuxdriver.com>
> > > Cc: netdev@vger.kernel.org
> > > ---
> > > 
> > >  net/core/drop_monitor.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> > > index 7f36b38..ef4a05d 100644
> > > --- a/net/core/drop_monitor.c
> > > +++ b/net/core/drop_monitor.c
> > > @@ -137,7 +137,7 @@ static void trace_drop_common(struct sk_buff *skb,
> > > void *location)
> > > 
> > >  	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
> > > 
> > > -	if (!atomic_add_unless(&data->dm_hit_count, -1, 0)) {
> > > +	if (!atomic_dec_not_zero(&data->dm_hit_count)) {
> > > 
> > >  		/*
> > >  		
> > >  		 * we're already at zero, discard this hit
> > >  		 */
> > 
> > Wheres the patch that creates the per arch definition of this function?  I
> > see the other posts in this series went to lkml, but the archives don't
> > have the first in the series anywhere, which ostensibly adds the
> > definition. Neil
> 
> Most architectures don't use a per architecture definition anymore, but a 
> cross-architecture the definition in include/linux/atomic.h.
> 
> The 01/11 can be found in different archives under the message id 
> 1311760070-21532-1-git-send-email-sven@narfation.org ... for example gmane: 
> http://article.gmane.org/gmane.linux.ports.arm.kernel/126704
> 
> Kind regards,
> 	Sven
Ok, thank you, I just didn't see the patch that implemented it in the lkml
archive at MARC, and wanted to be sure this wasn't proposed for a different tree
than the patch with the definition.

Acked-by: Neil Horman <nhorman@tuxdriver.com>
