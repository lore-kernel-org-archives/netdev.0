From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/4] samples/bpf: adjust rlimit RLIMIT_MEMLOCK
 for traceex2, tracex3 and tracex4
Date: Wed, 3 May 2017 10:12:13 +0200
Message-ID: <20170503101213.7eece6c9@redhat.com>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
        <149372831091.22268.12527267276516941574.stgit@firesoul>
        <20170503005314.7oovr764r3e4elzd@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51968 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751539AbdECIMU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 04:12:20 -0400
In-Reply-To: <20170503005314.7oovr764r3e4elzd@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 May 2017 17:53:16 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Tue, May 02, 2017 at 02:31:50PM +0200, Jesper Dangaard Brouer wrote:
> > Needed to adjust max locked memory RLIMIT_MEMLOCK for testing these bpf samples
> > as these are using more and larger maps than can fit in distro default 64Kbytes limit.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> ...
> > +	struct rlimit r = {1024*1024, RLIM_INFINITY};  
> ...
> > +	struct rlimit r = {1024*1024, RLIM_INFINITY};  
> 
> why magic numbers?
> All other samples do
> struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};

I just wanted to provide some examples showing that it is possible to
set some reasonable limit.

The RLIM_INFINITY setting is basically just disabling the kernels
memory limit checks, and it is sort of a bad coding pattern (that
people will copy) as the two example programs does not need much.

 
> > +	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
> > +		perror("setrlimit(RLIMIT_MEMLOCK)");  
> 
> ip_tunnel.c test does:
> perror("setrlimit(RLIMIT_MEMLOCK, RLIM_INFINITY)");
> Few others do:
> assert(!setrlimit(RLIMIT_MEMLOCK, &r));
> and the rest just:
> setrlimit(RLIMIT_MEMLOCK, &r);
> 
> We probalby need to move this to a helper.
> 
> > +	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};  
> 
> here it's consistent :)
> 
> > +	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
> > +		perror("setrlimit(RLIMIT_MEMLOCK, RLIM_INFINITY)");  
> 
> but with different perror ?
> Let's do a common helper for all?

Sure, it makes sense to streamline this into a helper, just not in this
patchset ;-)  Lets do that later...

And I would argue that this helper should allow users to specify some
expected/reasonable memory usage size, as the kernel side checks would
then provide some value, instead of being effectively disabled.  I can
easily imagine someone increasing a _kern.c hash map max size to
100 million, without realizing that this can OOM the machine.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
