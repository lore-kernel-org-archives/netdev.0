From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 5/9] bpf: syscall: add percpu version of lookup/update
 elem
Date: Tue, 12 Jan 2016 21:30:09 -0800
Message-ID: <20160113053009.GC37858@ast-mbp.thefacebook.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
 <1452527821-12276-6-git-send-email-tom.leiming@gmail.com>
 <20160111190248.GA26495@ast-mbp.thefacebook.com>
 <CACVXFVM7B6diKgrGoXdMkYW94SeY9yRxbv8bJ+J0K=TBGxDBQQ@mail.gmail.com>
 <20160112054928.GA31180@ast-mbp.thefacebook.com>
 <CACVXFVOyAm-X7WdC-OCau_tZCAmSJoHFh2p6do16SzFDD8EkUg@mail.gmail.com>
 <20160112191051.GA67436@kafai-mba.local>
 <CACVXFVOKRpPfVzAkeFq6vLkRG+JsK+GnmT5_YUBb4hZg3KjM1w@mail.gmail.com>
 <20160113022204.GA25270@kafai-mba.dhcp.thefacebook.com>
 <CACVXFVPK+1yKbOs2A73413bamssyNXFEq+j9LTs_vZxfTsxzGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACVXFVPK+1yKbOs2A73413bamssyNXFEq+j9LTs_vZxfTsxzGA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 11:17:23AM +0800, Ming Lei wrote:
> On Wed, Jan 13, 2016 at 10:22 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> > On Wed, Jan 13, 2016 at 08:38:18AM +0800, Ming Lei wrote:
> >> > The userspace usually only aggregates value across all cpu every X seconds.
> >>
> >> That is just in your case, and Alexei worried the issue of data stale.
> > I believe we are talking about validity of a value.  How to
> > make use of a less-stale but invalid data?
> 
> About the 'invalidity' thing, it should be same between using
> smp_call(run in IPI irq handler) and simple memcpy().
> 
> When smp_call_function_single() is used to request to lookup element in
> the specific CPU, the value of the element may be in updating in that CPU
> and not completed yet in eBPF prog, then IPI comes and half updated
> data is still returned to syscall.

hmm. I'm not following. bpf programs are executing with preempt disabled,
so smp_call_function_single suppose to execute when bpf is not running.
