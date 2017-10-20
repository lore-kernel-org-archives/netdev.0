From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 18/27] bpf: Restrict kernel image access functions when
 the kernel is locked down
Date: Fri, 20 Oct 2017 16:00:42 -0700
Message-ID: <20171020230040.qlz5rnegldcpzzb7@ast-mbp>
References: <20171020024732.GJ3285@linux-l9pv.suse>
 <150842463163.7923.11081723749106843698.stgit@warthog.procyon.org.uk>
 <150842476953.7923.18174368926573855810.stgit@warthog.procyon.org.uk>
 <20171019221829.7m5nczg3ltqmhzom@ast-mbp>
 <2582.1508486928@warthog.procyon.org.uk>
 <20171020155748.kzrvg6565oxh6gmb@linux-rasp2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        jforbes@redhat.com, Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Gary Lin <GLin@suse.com>
To: jlee@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:56709 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753061AbdJTXAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 19:00:46 -0400
Content-Disposition: inline
In-Reply-To: <20171020155748.kzrvg6565oxh6gmb@linux-rasp2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 11:57:48PM +0800, jlee@suse.com wrote:
> On Fri, Oct 20, 2017 at 09:08:48AM +0100, David Howells wrote:
> > Hi Joey,
> > 
> > Should I just lock down sys_bpf() entirely for now?  We can always free it up
> > somewhat later.
> > 
> > David
> 
> OK~~ Please just remove my patch until we find out a way to
> verify bpf code or protect sensitive data in memory.
> 
> I think that we don't need to lock down sys_bpf() now because
> we didn't lock down other interfaces for reading arbitrary
> address like /dev/mem and /dev/kmem.

If you want to lock down read access you'd need to disable
not only bpf, but all of kprobe and likey ftrace, since
untrusted root can infer kernel data by observing function
execution even if it cannot load modules and bpf progs.
