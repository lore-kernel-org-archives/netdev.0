From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch: Make --strict a default for files in
 drivers/net and net/
Date: Fri, 09 May 2014 13:56:15 -0700
Message-ID: <1399668975.2912.14.camel@joe-AO725>
References: <487acde009f61607863704e5dd9da7f151cf5be8.1399486274.git.joe@perches.com>
	 <20140509153748.e2467ab487404f07e818719e@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andy Whitcroft <apw@canonical.com>
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140509153748.e2467ab487404f07e818719e@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-05-09 at 15:37 -0500, Kim Phillips wrote:
> On Wed, 7 May 2014 11:13:26 -0700
> Joe Perches <joe@perches.com> wrote:
> 
> > Networking files are generally more strictly conformant to
> > linux-kernel style
> 
> checkpatch disagrees :) :
> 
> {drivers/}net/ :            ~10.8 CHECKs per .[hc] file
> everything else:            ~10   CHECKs per .[hc] file
> no net, no drivers/staging:  ~8.6 CHECKs per .[hc] file
> 
> (see [1] below for details).
> 
> > +		if ($found_file) {
> > +			if ($realfile =~ m@^(drivers/net/|net/)@) {
> 
> this isn't easily extensible/scalable to other subsystems, or
> say something like "all Freescale drivers."  Having it configurable
> in .checkpatch.conf might be a better solution, but I don't believe
> networking should be the only subsystem that can take advantage of
> the extra checkpatch CHECKs.

staging probably could too.

> Can we enable --strict universally in the Linux kernel, maybe like
> so:?

I don't think that's appropriate (yet?).

Anyone that wants --strict checking can either add
it on the command line or create a .checkpatch.conf
file with --strict in it.

> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
[]
> @@ -228,6 +228,7 @@ if ($tree) {
>                 print "Must be run from the top-level dir. of a kernel tree\n";
>                 exit(2);
>         }
> +       $check = 1;
>  }
>  
>  my $emitted_corrupt = 0;
> 
> fwiw, --strict has been set unconditionally in u-boot's
> .checkpatch.conf for over a year now, and has significantly reduced
> patch revision churn for simple mistakes like parenthesis alignment,
> spaces after a cast and/or before a semicolon...

Good to know.

> [1] the following were run on kernel v3.15-rc4-260-g38583f0:
> 
> for i in `git ls-files | grep -v '^net/' | grep -v '^drivers/net/' | grep \\\.[ch]$`; do scripts/checkpatch.pl --strict -f $i; done | grep ^CHECK: | wc -l
> 328329
> git ls-files | grep -v '^net/' | grep -v '^drivers/net/' | grep \\\.[ch]$ | wc -l
> 32754
> => 32754 / 328329 ~= 10 CHECKs per file.[ch] for everything outside of {drivers/}net/.
> 
> for i in `git ls-files net/ drivers/net/ | grep \\\.[ch]$`; do scripts/checkpatch.pl --strict -f $i; done | grep ^CHECK: | wc -l
> 40431
> git ls-files net/ drivers/net/ | grep \\\.[ch]$ | wc -l
> 3742
> => {drivers/}net/: 40431 / 3742 = 10.8 CHECKs per file.[hc]
> 
> for i in `git ls-files | grep -v '^net/' | grep -v '^drivers/net/' | grep -v '^drivers/staging/' | grep \\\.[ch]$`; do scripts/checkpatch.pl --strict -f $i; done | grep ^CHECK: | wc -l
> 262005
> git ls-files | grep -v '^net/' | grep -v '^drivers/net/' | grep -v '^drivers/staging/' | grep \\\.[ch]$ | wc -l
> 30479
> => no net, no staging:  262005 / 30479  =  8.6 CHECKs per file.[hc]

Try that with a per-file "wc -l" for checks per LOC
