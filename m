From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Tool for sampling /proc/net/softnet_stat statistics
Date: Tue, 5 Jul 2016 14:20:32 +0200
Message-ID: <20160705142032.077eabd0@redhat.com>
References: <20160307163607.1da5f17e@redhat.com>
	<CAF=yD-LE3WnYZaNUX8h1-uRA2ZzMczrL=Ob4Qb39hhyAEqYMPA@mail.gmail.com>
	<20160308105056.5bb35bff@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	erdnetdev@gmail.com
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160308105056.5bb35bff@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Mar 2016 10:50:56 +0100
Jesper Dangaard Brouer <jbrouer@redhat.com> wrote:

> On Mon, 7 Mar 2016 12:54:13 -0500
> Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:
> 
> > On Mon, Mar 7, 2016 at 10:36 AM, Jesper Dangaard Brouer
> > <jbrouer@redhat.com> wrote:  
> > > Hi Google,
> > >
> > > While playing with RPS, I needed to read stats from
> > > /proc/net/softnet_stat and the tools I could find [1] and [2] was not
> > > very good.
> > >
> > > I lack of better, I coded up my own tool softnet_stat.pl here:
> > >  https://github.com/netoptimizer/network-testing/blob/master/bin/softnet_stat.pl
> > >
> > > The output format/columns in /proc/net/softnet_stat is undocumented,
> > > plus values are printed in hex.  E.g. to decode the columns you need to
> > > read kernel function kernel softnet_seq_show() in
> > > kernel/net/core/net-procfs.c.
> > >
> > > To make things easier I wrote this small perl script for get
> > > so human readable statistics from /proc/net/softnet_stat.    
> > 
> > Very nice. Thanks for sharing, Jesper. I maintained something similar,
> > but never got around to clean up and upstream it. Will start using
> > yours, instead.
> > 
> > A few points, from using my earlier tool:
> > 
> > A minimum cut-off value is helpful, especially on beefy servers, to
> > suppress the many 0 rows. Preferably configurable, to also be able to
> > suppress low-rate background traffic when analyzing a few large
> > streams. My default was 500.
> > 
> > The number of columns has grown with kernel versions. The latest
> > column is flow_limit, added in 3.11 at99bbc7074190. It is helpful for
> > the script to be robust against both older and future kernels. On
> > which note, to be able to support these kinds of tools, any new
> > columns to such procfs files should be appended, not inserted as for
> > instance in https://patchwork.ozlabs.org/patch/574171/
> > 
> > Time squeeze is an exception, in that it is number of squeeze events
> > per second, not number of packets squeezed. This is often
> > misunderstood if not explained clearly.  
> 
> Thanks a lot for your feedback.  I don't have time to address it right
> away, so I've instead added a section with future development todo's.
> So, I don't forget this valuable feedback :-)
> 
> https://github.com/netoptimizer/network-testing/commit/c464676e456aab

Found a bug in my script:
 https://github.com/netoptimizer/network-testing/blob/master/bin/softnet_stat.pl

It was not showing the "squeezed" events.

It is now fixed:
 https://github.com/netoptimizer/network-testing/commit/3b5ca843cf

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
