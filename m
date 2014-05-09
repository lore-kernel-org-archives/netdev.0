From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH] checkpatch: Make --strict a default for files in
 drivers/net and net/
Date: Fri, 9 May 2014 16:29:14 -0500
Message-ID: <20140509162914.8f8ac84b3a973820a21e5c2d@freescale.com>
References: <487acde009f61607863704e5dd9da7f151cf5be8.1399486274.git.joe@perches.com>
	<20140509153748.e2467ab487404f07e818719e@freescale.com>
	<1399668975.2912.14.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Andy Whitcroft <apw@canonical.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399668975.2912.14.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 May 2014 13:56:15 -0700
Joe Perches <joe@perches.com> wrote:

> On Fri, 2014-05-09 at 15:37 -0500, Kim Phillips wrote:
> > On Wed, 7 May 2014 11:13:26 -0700
> > Joe Perches <joe@perches.com> wrote:
> > 
> > > Networking files are generally more strictly conformant to
> > > linux-kernel style
> > 
> > checkpatch disagrees :) :
> > 
> > {drivers/}net/ :            ~10.8 CHECKs per .[hc] file
> > everything else:            ~10   CHECKs per .[hc] file
> > no net, no drivers/staging:  ~8.6 CHECKs per .[hc] file
> > 
> > (see [1] below for details).
> > 
> > > +		if ($found_file) {
> > > +			if ($realfile =~ m@^(drivers/net/|net/)@) {
> > 
> > this isn't easily extensible/scalable to other subsystems, or
> > say something like "all Freescale drivers."  Having it configurable
> > in .checkpatch.conf might be a better solution, but I don't believe
> > networking should be the only subsystem that can take advantage of
> > the extra checkpatch CHECKs.
> 
> staging probably could too.

why call staging out to be subject to stricter checks than the rest
of the kernel, when it's code that's _known_ to be non-compliant?

> > Can we enable --strict universally in the Linux kernel, maybe like
> > so:?
> 
> I don't think that's appropriate (yet?).

why not?  checkpatch CHECKs seem reasonably stable AFAICT.

> Anyone that wants --strict checking can either add
> it on the command line

most aren't aware of --strict, and even if they are, easily forget
to add it.

> or create a .checkpatch.conf
> file with --strict in it.

right, but since checkpatch already has internal knowledge of the
linux kernel, I thought it inappropriate to add a .checkpatch.conf,
and use the $tree switch.

> > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> []
> > @@ -228,6 +228,7 @@ if ($tree) {
> >                 print "Must be run from the top-level dir. of a kernel tree\n";
> >                 exit(2);
> >         }
> > +       $check = 1;
> >  }
> >  
> >  my $emitted_corrupt = 0;
> > 
> > fwiw, --strict has been set unconditionally in u-boot's
> > .checkpatch.conf for over a year now, and has significantly reduced
> > patch revision churn for simple mistakes like parenthesis alignment,
> > spaces after a cast and/or before a semicolon...
> 
> Good to know.

would an alternative option be to promote CHECKs like parentheses
alignment to WARN status?

> > [1] the following were run on kernel v3.15-rc4-260-g38583f0:
> > 
> > for i in `git ls-files | grep -v '^net/' | grep -v '^drivers/net/' | grep \\\.[ch]$`; do scripts/checkpatch.pl --strict -f $i; done | grep ^CHECK: | wc -l
> > 328329
> > git ls-files | grep -v '^net/' | grep -v '^drivers/net/' | grep \\\.[ch]$ | wc -l
> > 32754
> > => 32754 / 328329 ~= 10 CHECKs per file.[ch] for everything outside of {drivers/}net/.
> > 
> > for i in `git ls-files net/ drivers/net/ | grep \\\.[ch]$`; do scripts/checkpatch.pl --strict -f $i; done | grep ^CHECK: | wc -l
> > 40431
> > git ls-files net/ drivers/net/ | grep \\\.[ch]$ | wc -l
> > 3742
> > => {drivers/}net/: 40431 / 3742 = 10.8 CHECKs per file.[hc]
> > 
> > for i in `git ls-files | grep -v '^net/' | grep -v '^drivers/net/' | grep -v '^drivers/staging/' | grep \\\.[ch]$`; do scripts/checkpatch.pl --strict -f $i; done | grep ^CHECK: | wc -l
> > 262005
> > git ls-files | grep -v '^net/' | grep -v '^drivers/net/' | grep -v '^drivers/staging/' | grep \\\.[ch]$ | wc -l
> > 30479
> > => no net, no staging:  262005 / 30479  =  8.6 CHECKs per file.[hc]
> 
> Try that with a per-file "wc -l" for checks per LOC

good point, that reinforces the statement back for networking :) :

{drivers/}net/ :            0.013 CHECKs per .[hc] file line
everything else:            0.43  CHECKs per .[hc] file line
no net, no drivers/staging: 0.38  CHECKs per .[hc] file line

Thanks,

Kim
