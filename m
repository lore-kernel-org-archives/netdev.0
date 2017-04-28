From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Strange samples/bpf loading error for maps on net-next?
Date: Thu, 27 Apr 2017 22:49:51 -0700
Message-ID: <20170428054950.teh53ssg6ei4xkvx@ast-mbp>
References: <20170427131542.3c8dfa24@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>, eric@regit.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34375 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163861AbdD1Ftz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 01:49:55 -0400
Received: by mail-pf0-f196.google.com with SMTP id g23so15841901pfj.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 22:49:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170427131542.3c8dfa24@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 01:15:42PM +0200, Jesper Dangaard Brouer wrote:
> 
> To provoke this bug, remember that you MUST call:
> 
>  make headers_install
> 
> In the kernels root directory, else you will be compiling samples/bpf/
> against the older headers previously installed.
> 
> The error looks like:
> 
>  $ sudo ./sockex1
>  bpf_load_program() err=22
>  fd 0 is not pointing to valid bpf_map
>  sockex1: [...]/samples/bpf/sockex1_user.c:26: main: Assertion `setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, prog_fd, sizeof(prog_fd[0])) == 0' failed.
>  Aborted
> 
> I've found that the bug were introduced in
>  commit: fb30d4b71214 ("bpf: Add tests for map-in-map")

Great debugging!
Indeed that change made samples/bpf/bpf_load.c to be incompatible with .o
generated earlier. We should really get rid of that loader and
switch to tools/lib/bpf/. I believe Eric Leblond already made it
resilient to 'struct bpf_map_def' changes.
