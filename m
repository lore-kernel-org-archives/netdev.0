From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix samples to add fake KBUILD_MODNAME
Date: Sat, 29 Oct 2016 14:46:35 -0400 (EDT)
Message-ID: <20161029.144635.1746337676131700468.davem@davemloft.net>
References: <1fdac65566ed6e0cff486507c5019f45807d1e89.1477434641.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51632 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbcJ2Sqh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 14:46:37 -0400
In-Reply-To: <1fdac65566ed6e0cff486507c5019f45807d1e89.1477434641.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 26 Oct 2016 00:37:53 +0200

> Some of the sample files are causing issues when they are loaded with tc
> and cls_bpf, meaning tc bails out while trying to parse the resulting ELF
> file as program/map/etc sections are not present, which can be easily
> spotted with readelf(1).
> 
> Currently, BPF samples are including some of the kernel headers and mid
> term we should change them to refrain from this, really. When dynamic
> debugging is enabled, we bail out due to undeclared KBUILD_MODNAME, which
> is easily overlooked in the build as clang spills this along with other
> noisy warnings from various header includes, and llc still generates an
> ELF file with mentioned characteristics. For just playing around with BPF
> examples, this can be a bit of a hurdle to take.
> 
> Just add a fake KBUILD_MODNAME as a band-aid to fix the issue, same is
> done in xdp*_kern samples already.
> 
> Fixes: 65d472fb007d ("samples/bpf: add 'pointer to packet' tests")
> Fixes: 6afb1e28b859 ("samples/bpf: Add tunnel set/get tests.")
> Fixes: a3f74617340b ("cgroup: bpf: Add an example to do cgroup checking in BPF")
> Reported-by: Chandrasekar Kannan <ckannan@console.to>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
