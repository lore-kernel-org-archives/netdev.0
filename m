From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and
 coding-style
Date: Sun, 09 Jan 2011 21:55:41 +0000
Message-ID: <1294610141.2823.31.camel@localhost>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be>
	 <20110109130608.5c7bb4b0.rdunlap@xenotime.net>
	 <201101092232.19171.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201101092232.19171.christoph.paasch@uclouvain.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-01-09 at 22:32 +0100, Christoph Paasch wrote:
> Hello,
> 
> On Sunday, January 09, 2011 wrote Randy Dunlap:
> > On Sun,  9 Jan 2011 21:55:34 +0100 Christoph Paasch wrote:
> > If there is something in net/tcp.h that uses data or functions from
> > <linux/list.h>, then <linux/list.h> should be #included in net/tcp.h,
> > whether some other file pulls it in indirectly or not.
> > 
> > etc. etc. etc.
> Why?
> 
> IMHO I think that it increases compile-time.
> Ok, here in that case it only increases it slightly (probably it isn't even 
> measurable).

The cost of repeated inclusion is minimal.  GCC's preprocessor
recognises when the entire content of a file is conditional on #ifndef
FOO and will not even open it again if FOO is defined.

>  But, if *all* the files would be more strict in including, I'm 
> sure that it would make a difference.
> The less files you include, the faster the compilation will be.
> 
> In net/tcp.h there were even 4 unnecessary included files.
> 
> And, then we would also need to include:
> net/net_namespace.h (for struct net)
> 
> Also, I think that it makes the code more readable and also easier to 
> maintain. The more files we include, the bigger the chance is that we will end 
> up with plenty of files unnecessarily included, and thus the compile-time will 
> explode.

If a file directly references definitions that are supposed to be
provided by a certain header, changing it to rely on indirect inclusion
of that header generally does *not* aid maintenance.

(There are some cases where you should rely on indirect inclusion, such
as where <linux/foo.h> includes <asm/foo.h>.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
