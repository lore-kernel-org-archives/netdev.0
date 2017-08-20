From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [net-next:master 1184/1189] include/linux/bpf.h:324:21: error:
 'NUMA_NO_NODE' undeclared
Date: Sat, 19 Aug 2017 23:27:47 -0700
Message-ID: <20170820062747.3k4tduu7w3ahxy5x@kafai-mba.local>
References: <201708201349.qPOeS6kf%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <kbuild-all@01.org>
To: <netdev@vger.kernel.org>,
        kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35030 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751607AbdHTG14 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 02:27:56 -0400
Content-Disposition: inline
In-Reply-To: <201708201349.qPOeS6kf%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 20, 2017 at 01:43:54PM +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   228498596c44041c710f5a633904205bc1cd9177
> commit: 96eabe7a40aa17e613cf3db2c742ee8b1fc764d0 [1184/1189] bpf: Allow selecting numa node during map creation
> config: i386-randconfig-s1-201734 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout 96eabe7a40aa17e613cf3db2c742ee8b1fc764d0
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All error/warnings (new ones prefixed by >>):
>
>    In file included from net/bpf/test_run.c:7:0:
>    include/linux/bpf.h: In function 'bpf_map_attr_numa_node':
> >> include/linux/bpf.h:324:21: error: 'NUMA_NO_NODE' undeclared (first use in this function)
>       attr->numa_node : NUMA_NO_NODE;
>                         ^~~~~~~~~~~~
>    include/linux/bpf.h:324:21: note: each undeclared identifier is reported only once for each function it appears in
> --
>    In file included from kernel/bpf/syscall.c:12:0:
>    include/linux/bpf.h: In function 'bpf_map_attr_numa_node':
> >> include/linux/bpf.h:324:21: error: 'NUMA_NO_NODE' undeclared (first use in this function)
>       attr->numa_node : NUMA_NO_NODE;
>                         ^~~~~~~~~~~~
>    include/linux/bpf.h:324:21: note: each undeclared identifier is reported only once for each function it appears in
>    In file included from kernel/bpf/syscall.c:12:0:
> >> include/linux/bpf.h:325:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^
I will post a fix shortly.

>
> vim +/NUMA_NO_NODE +324 include/linux/bpf.h
>
>    319
>    320	/* Return map's numa specified by userspace */
>    321	static inline int bpf_map_attr_numa_node(const union bpf_attr *attr)
>    322	{
>    323		return (attr->map_flags & BPF_F_NUMA_NODE) ?
>  > 324			attr->numa_node : NUMA_NO_NODE;
>  > 325	}
>    326
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://urldefense.proofpoint.com/v2/url?u=https-3A__lists.01.org_pipermail_kbuild-2Dall&d=DwIBAg&c=5VD0RTtNlTh3ycd41b3MUw&r=VQnoQ7LvghIj0gVEaiQSUw&m=36OvwN5FPWpOV3AefLVno0fEHrg6mcU_F6ErzV-KPlc&s=EDsqfhvtP3I95wiIrIqYE8CEAk6wnfUAuVWkCb3iXP4&e=                    Intel Corporation
