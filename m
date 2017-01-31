From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv3 perf/core 1/6] tools lib bpf: Add BPF program pinning
 APIs.
Date: Tue, 31 Jan 2017 13:13:20 -0300
Message-ID: <20170131161320.GB4529@kernel.org>
References: <20170126212001.14103-1-joe@ovn.org>
 <20170126212001.14103-2-joe@ovn.org>
 <20170130202506.GF4546@kernel.org>
 <20170130202813.GG4546@kernel.org>
 <CAPWQB7FDThp03e6DTHio8Myv5e8J6RcDXK-jG8W6B7Sh2Gvisw@mail.gmail.com>
 <20170131005805.GI4546@kernel.org>
 <20170131160827.GA4529@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Nan <wangnan0@huawei.com>, ast@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170131160827.GA4529@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Jan 31, 2017 at 01:08:27PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Mon, Jan 30, 2017 at 09:58:05PM -0300, Arnaldo Carvalho de Melo escreveu:
> > Em Mon, Jan 30, 2017 at 01:16:18PM -0800, Joe Stringer escreveu:
> > > On 30 January 2017 at 12:28, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> > > > ---
> > > > Thus, a return value of size or more means that the output was
> > > > truncated.
> > > > ---
> >  
> > > Good spotting, I looked over the committed versions and tested them,
> > > they seem good to me. Thanks!
> > 
> > Thanks for checking, will push Ingo's way after a battery of extra
> > tests, tomorrow,
> 
> Which failed for centos:5, centos:6, centos:7, debian:7, debian:8,
> debian:experimental and others, I stopped the test at this point,
> working on fixing it.
> 
> All seems related to:
> 
> libbpf.c:1267: error: 'BPF_FS_MAGIC' undeclared (first use in this function)
> libbpf.c:1267: error: (Each undeclared identifier is reported only once
> libbpf.c:1267: error: for each function it appears in.)

We need to carry a tools/include/uapi/linux/magic.c copy, check if it
drifts, remove the ifdefs for _FS_MAGIC defines from tools/ and use that
instead, etc, till then I'll just add the ifdef to libbpf.c.

[acme@jouet linux]$ grep BPF_FS_MAGIC /usr/include/*/*.h
/usr/include/linux/magic.h:#define BPF_FS_MAGIC		0xcafe4a11
[acme@jouet linux]$ rpm -qf /usr/include/linux/magic.h
kernel-headers-4.9.6-200.fc25.x86_64
[acme@jouet linux]$ cat /etc/fedora-release 
Fedora release 25 (Twenty Five)
[acme@jouet linux]$ 

But those other distros don't have it.

- Arnaldo
