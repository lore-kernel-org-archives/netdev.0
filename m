From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net-next 0/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Fri, 8 Jan 2016 14:55:32 +0800
Message-ID: <CACVXFVNhEOrroAfiEOC32dB3ZV=73WYJxUtNrpqEE94tvY2fXw@mail.gmail.com>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:36539 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbcAHGzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 01:55:33 -0500
In-Reply-To: <1452206155-1492617-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

On Fri, Jan 8, 2016 at 6:35 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> This patchset adds BPF_MAP_TYPE_PERCPU_HASH map type which allows
> percpu value.

I am also thinking about using percpu variable to ebpf map, but IMO it
should be better for ARRAY map instead of HASH map, then we can
avoid the atomic op in eBPF program, see example of tracex3, sockex1
and sockex3 in sample/bpf/ of kernel tree.  Also looks the ARRAY map
usage in bcc is wrong, strictly speaking.

For HASH map, it is easy to make cpu id as part of key, then the map
can be thought as percpu too, and atomic op isn't needed in eBPF program.

> BPF + kprobe is very useful in statistics collection.  In particular,
> bpf is strong in doing aggregation within the kernel instead of
> outputting a lot of raw samples to the userspace.

Exactly, :-)

>
> In some cases, bumping a counter/value of a particular key will have
> noticeable impact.  For example, doing statistics collection
> on received packets and aggregating them by network
> prefix (like /64 in IPv6).  Having a percpu value can help.

Given it is always related with performance, could you provide some data
about the improvement? Also you can compare this patchset with the
approach of providing cpu id as hash key.


-- 
Ming Lei
