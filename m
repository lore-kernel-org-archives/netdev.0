From: Wouter Verhelst <w@uter.be>
Subject: Re: [PATCH 3/4] treewide: convert PF_MEMALLOC manipulations
 to new helpers
Date: Thu, 6 Apr 2017 08:38:10 +0200
Message-ID: <20170406063810.dmv4fg2irsqgdvyq@grep.be>
References: <20170405074700.29871-1-vbabka@suse.cz>
	<20170405074700.29871-4-vbabka@suse.cz>
	<20170405113030.GL6035@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nbd-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Josef Bacik <jbacik-b10kYP2dOMg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Lee Duncan <lduncan-IBi9RG/b67k@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Mel Gorman <mgorman-3eNAlZScCAx27rWaFMvyedHuzzzSOjJt@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>
To: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170405113030.GL6035-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nbd-general>,
	<mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nbd-general>
List-Post: <mailto:nbd-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nbd-general>,
	<mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 05, 2017 at 01:30:31PM +0200, Michal Hocko wrote:
> On Wed 05-04-17 09:46:59, Vlastimil Babka wrote:
> > We now have memalloc_noreclaim_{save,restore} helpers for robust setting and
> > clearing of PF_MEMALLOC. Let's convert the code which was using the generic
> > tsk_restore_flags(). No functional change.
> 
> It would be really great to revisit why those places outside of the mm
> proper really need this flag. I know this is a painful exercise but I
> wouldn't be surprised if there were abusers there.
[...]
> > ---
> >  drivers/block/nbd.c      | 7 ++++---
> >  drivers/scsi/iscsi_tcp.c | 7 ++++---
> >  net/core/dev.c           | 7 ++++---
> >  net/core/sock.c          | 7 ++++---
> >  4 files changed, 16 insertions(+), 12 deletions(-)

These were all done to make swapping over network safe. The idea is that
if a socket has SOCK_MEMALLOC set, incoming packets for that socket can
access PFMEMALLOC reserves (whereas other sockets cannot); this all in
the hope that one packe destined to that socket will contain the TCP ACK
that confirms the swapout was successful and we can now release RAM
pages for other processes.

I don't know whether they need the PF_MEMALLOC flag specifically (not a
kernel hacker), but they do need to interact with it at any rate.

-- 
< ron> I mean, the main *practical* problem with C++, is there's like a dozen
       people in the world who think they really understand all of its rules,
       and pretty much all of them are just lying to themselves too.
 -- #debian-devel, OFTC, 2016-02-12

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
