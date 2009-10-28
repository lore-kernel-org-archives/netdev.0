From: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Date: Wed, 28 Oct 2009 11:59:26 +0000
Message-ID: <20091028115926.GW8900@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091023165810.GA4588@bizet.domek.prywatny> <20091023211239.GA6185@bizet.domek.prywatny> <9ec2d7290910240646p75b93c68v6ea1648d628a9660@mail.gmail.com> <20091028114208.GA14476@bizet.domek.prywatny>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Mel LKML <mel.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Sven Geggus <lists-+AJD3D7QEjjt/htJsj1pd9AswbaBtrod@public.gmane.org>,
	Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Mohamed Abbas <mohamed.abbas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
To: Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091028114208.GA14476-nLtalAL5mPp2RxbNQum0x1nzlInOXLuq@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2009 at 12:42:08PM +0100, Karol Lewandowski wrote:
> On Sat, Oct 24, 2009 at 02:46:56PM +0100, Mel LKML wrote:
> > Hi,
> 
> Hi,
> 
> > On 10/23/09, Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > > On Fri, Oct 23, 2009 at 06:58:10PM +0200, Karol Lewandowski wrote:
> 
> > > Ok, I've tested patches 1+2+4 and bug, while very hard to trigger, is
> > > still present. I'll test complete 1-4 patchset as time permits.
> 
> Sorry for silence, I've been quite busy lately.
> 
> 
> > And also patch 5 please which is the revert. Patch 5 as pointed out is
> > probably a red herring. Hwoever, it has changed the timing and made a
> > difference for some testing so I'd like to know if it helps yours as
> > well.
> 
> I've tested patches 1+2+3+4 in my normal usage scenario (do some work,
> suspend, do work, suspend, ...) and it failed today after 4 days (== 4
> suspend-resume cycles).
> 
> I'll test 1-5 now.
> 

I was digging through commits for suspend-related changes. Rafael, is
there any chance that some change to suspend is responsible for this
regression? This commit for example is a vague possibility;
c6f37f12197ac3bd2e5a35f2f0e195ae63d437de: PM/Suspend: Do not shrink memory before suspend

I say vague because FREE_PAGE_NUMBER is so small.

Also, what was the behaviour of the e100 driver when suspending before
this commit?

6905b1f1a03a48dcf115a2927f7b87dba8d5e566: Net / e100: Fix suspend of devices that cannot be power managed

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
