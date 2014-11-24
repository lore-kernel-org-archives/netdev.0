From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: [PATCH 0/6] kernel tinification: optionally compile out splice
 family of syscalls (splice, vmsplice, tee and sendfile)
Date: Mon, 24 Nov 2014 09:38:20 +0100
Message-ID: <CAMuHMdW8gAiyFiPHu-N4Dg_+b6Qg9JXZZ3PqOn=VmZLcEH-Xkg@mail.gmail.com>
References: <1416752468-1626-1-git-send-email-pieter@boesman.nl>
	<20141123.134623.2061031332250984539.davem@davemloft.net>
	<20141123194326.GB8517@thin>
	<20141123203040.GB26749@smipidev>
	<20141123233637.GC12456@thin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org,
	catalina.mocanu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>,
	fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	iulia.manda21-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Jan Beulich <JBeulich-IBi9RG/b67k@public.gmane.org>,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>,
	Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Miklos S
To: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141123233637.GC12456@thin>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2014 at 12:36 AM, Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org> wrote:
> On Sun, Nov 23, 2014 at 09:30:40PM +0100, Pieter Smith wrote:
>> On Sun, Nov 23, 2014 at 11:43:26AM -0800, Josh Triplett wrote:
>> > On Sun, Nov 23, 2014 at 01:46:23PM -0500, David Miller wrote:
>> > > Truly removing sendfile/sendpage means that you can't even compile NFS
>> > > into the tree.
>> >
>> > If you mean the in-kernel nfsd (CONFIG_NFSD), that already has a large
>> > stack of "select" and "depends on", both directly and indirectly; adding
>> > a "select SPLICE_SYSCALL" to it seems fine.  (That select does need
>> > adding, though.  Pieter, you need to test-compile more than just
>> > tinyconfig and defconfig.  Try an allyesconfig with *just* splice turned
>> > off, and make sure that compiles.)
>>
>> Did exacly that. Took forever on my hardware, but no problems.
>
> Ah, I see.  Looking more closely at nfsd, it looks like it already has a
> code path for filesystems that don't do splice.  I think, rather than
> making nfsd select SPLICE_SYSCALL, that it would suffice to change the
> "rqstp->rq_splice_ok = true;" in svc_process_common (net/sunrpc/svc.c)
> to:
>
> rqstp->rq_splice_ok = IS_ENABLED(CONFIG_SPLICE_SYSCALL);
>
> Then nfsd should simply *always* fall back to its non-splice support.

Hence I suggest adding to the nfsd help text:

    While nfsd works without SPLICE_SYSCALL, you may want to enable
    SPLICE_SYSCALL for <...> (performance?) reasons.

(Hmm, does Kconfig need a "suggests", cfr. Debian package dependencies?)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
