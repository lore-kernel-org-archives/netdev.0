From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 1/4] samples/bpf: adjust rlimit RLIMIT_MEMLOCK
 for traceex2, tracex3 and tracex4
Date: Tue, 2 May 2017 17:53:16 -0700
Message-ID: <20170503005314.7oovr764r3e4elzd@ast-mbp>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
 <149372831091.22268.12527267276516941574.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kafai@fb.com, netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35111 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdECAxU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 20:53:20 -0400
Received: by mail-pf0-f196.google.com with SMTP id o68so1700161pfj.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 17:53:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <149372831091.22268.12527267276516941574.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 02, 2017 at 02:31:50PM +0200, Jesper Dangaard Brouer wrote:
> Needed to adjust max locked memory RLIMIT_MEMLOCK for testing these bpf samples
> as these are using more and larger maps than can fit in distro default 64Kbytes limit.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
...
> +	struct rlimit r = {1024*1024, RLIM_INFINITY};
...
> +	struct rlimit r = {1024*1024, RLIM_INFINITY};

why magic numbers?
All other samples do
struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 
> +	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
> +		perror("setrlimit(RLIMIT_MEMLOCK)");

ip_tunnel.c test does:
perror("setrlimit(RLIMIT_MEMLOCK, RLIM_INFINITY)");
Few others do:
assert(!setrlimit(RLIMIT_MEMLOCK, &r));
and the rest just:
setrlimit(RLIMIT_MEMLOCK, &r);

We probalby need to move this to a helper.

> +	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};

here it's consistent :)

> +	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
> +		perror("setrlimit(RLIMIT_MEMLOCK, RLIM_INFINITY)");

but with different perror ?
Let's do a common helper for all?
