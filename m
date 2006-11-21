From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: 2.6.19-rc6 : Spontaneous reboots, stack overflows - seems to implicate xfs, scsi, networking, SMP
Date: Wed, 22 Nov 2006 00:51:43 +0100
Message-ID: <9a8748490611211551v2ebe88fel2bcf25af004c338a@mail.gmail.com>
References: <200611211027.41971.jesper.juhl@gmail.com>
	 <45637566.5020802@melbourne.sgi.com>
	 <9a8748490611211402xdc2822fqbc95a77fe54d49b1@mail.gmail.com>
	 <20061121233141.GP37654165@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chatz@melbourne.sgi.com, LKML <linux-kernel@vger.kernel.org>,
	xfs@oss.sgi.com, xfs-masters@oss.sgi.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: "David Chinner" <dgc@sgi.com>
In-Reply-To: <20061121233141.GP37654165@melbourne.sgi.com>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/11/06, David Chinner <dgc@sgi.com> wrote:
> On Tue, Nov 21, 2006 at 11:02:23PM +0100, Jesper Juhl wrote:
> > On 21/11/06, David Chatterton <chatz@melbourne.sgi.com> wrote:
...
>
> > >Audits have been done in the past and will again be done in the future to
> > >try to
> > >identify areas where XFS could use less stack space by reducing/avoid large
> > >local variables. Reducing the code path is far more difficult.
> > >
> > I realize that fixing the problem may be difficult. I just wanted to
> > make sure that people were informed that there is an actual problem
> > and provide as much info as possible so that perhaps in the future it
> > can be fixed... :)
>
> I've got one that prevents gcc from inlining single use functions in XFS
> that I need to finish off, and that results in some significant stack
> usage reductions in some XFS functions.
>
That sounds good. I'll be keeping an eye out for that one :)

> However, XFS is only one part of the picture - when you put NFS on top,
> DM+md then scsi/FC below and then you nest a soft irq that might go
> 20 functions deep as well - then 4k stacks simply aren't big enough.
>
True, there are a lot of players involved here, although XFS seems (to
me) to be the biggest one.

> > I'm reading through the XFS code myself at the moment and I'll be sure
> > to submit patches if I spot something that could help reduce stack
> > usage.
>
> Most of the low hanging fruit is already gone. The problem we are
> facing now for further reductions in stack usage is the fact that we
> need to factor code. That is a major undertaking and has a _lot_ of
> risk associated with it....
>
I'll try to spot some of the remaining low hanging fruit ;)


> > >There is active discussion about reducing inlining:
> > >http://bugzilla.kernel.org/show_bug.cgi?id=7364
> >
> > Thanks, I'll check that out.
>
> That's one of the few remaining low hanging fruit, and that's fixed
> in the patches I already have.
>
Nice. Will be good to get that in.


> > >Thanks for traces, I've captured this information.
> > >
> > You are welcome. If you want/need more traces then I've got ~2.1G
> > worth of traces that you can have :)
>
> Well, we don't need that many, but it would be nice to have a
> set of unique traces that lead to overflows - could you process
> them in some way just to extract just the unique XFS traces that
> occur?
>
I'll try to extract a copy of each unique trace that involves xfs,
sometime tomorrow or the day after, and then send you the result.


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
