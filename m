From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] samples/bpf: Enable powerpc support
Date: Fri, 1 Apr 2016 20:11:31 +0530
Message-ID: <20160401144131.GG17907@naverao1-tp.ibm.com>
References: <922f95fb5d16686367a66d2d4bd176149a87e9ad.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <28a3811d03f6e8f7dca989a4ade536bf9aa8c7ce.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <56FD63F4.2010500@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56FD63F4.2010500@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/03/31 10:52AM, Alexei Starovoitov wrote:
> On 3/31/16 4:25 AM, Naveen N. Rao wrote:
> ...
> >+
> >+#ifdef __powerpc__
> >+#define BPF_KPROBE_READ_RET_IP(ip, ctx)		{ (ip) = (ctx)->link; }
> >+#define BPF_KRETPROBE_READ_RET_IP(ip, ctx)	BPF_KPROBE_READ_RET_IP(ip, ctx)
> >+#else
> >+#define BPF_KPROBE_READ_RET_IP(ip, ctx)						\
> >+		bpf_probe_read(&(ip), sizeof(ip), (void *)PT_REGS_RET(ctx))
> >+#define BPF_KRETPROBE_READ_RET_IP(ip, ctx)					\
> >+		bpf_probe_read(&(ip), sizeof(ip),				\
> >+				(void *)(PT_REGS_FP(ctx) + sizeof(ip)))
> 
> makes sense, but please use ({ }) gcc extension instead of {} and
> open call to make sure that macro body is scoped.

To be sure I understand this right, do you mean something like this?

+
+#ifdef __powerpc__
+#define BPF_KPROBE_READ_RET_IP(ip, ctx)                ({ (ip) = (ctx)->link; })
+#define BPF_KRETPROBE_READ_RET_IP              BPF_KPROBE_READ_RET_IP
+#else
+#define BPF_KPROBE_READ_RET_IP(ip, ctx)                ({                              \
+               bpf_probe_read(&(ip), sizeof(ip), (void *)PT_REGS_RET(ctx)); })
+#define BPF_KRETPROBE_READ_RET_IP(ip, ctx)     ({                              \
+               bpf_probe_read(&(ip), sizeof(ip),                               \
+                               (void *)(PT_REGS_FP(ctx) + sizeof(ip))); })
+#endif
+


Thanks,
Naveen
