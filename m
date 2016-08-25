From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 2/6] cgroup: add support for eBPF programs
Date: Thu, 25 Aug 2016 14:56:11 +0800
Message-ID: <201608251417.1LeHqi8c%fengguang.wu@intel.com>
References: <1472070263-29988-3-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, Daniel Mack <daniel@zonque.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:27032 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755279AbcHYHBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 03:01:25 -0400
Content-Disposition: inline
In-Reply-To: <1472070263-29988-3-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.8-rc3 next-20160824]
[cannot apply to linus/master linux/master]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
[Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
[Check https://git-scm.com/docs/git-format-patch for more information]

url:    https://github.com/0day-ci/linux/commits/Daniel-Mack/Add-eBPF-hooks-for-cgroups/20160825-042759
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:230:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> kernel/bpf/cgroup.c:46:17: sparse: incompatible types in comparison expression (different address spaces)
>> kernel/bpf/cgroup.c:46:17: sparse: incompatible types in comparison expression (different address spaces)
   kernel/bpf/cgroup.c:97:17: sparse: incompatible types in comparison expression (different address spaces)
   kernel/bpf/cgroup.c:147:16: sparse: incompatible types in comparison expression (different address spaces)

vim +46 kernel/bpf/cgroup.c

    30				continue;
    31	
    32			bpf_prog_put(cgrp->bpf.prog[type]);
    33			static_branch_dec(&cgroup_bpf_enabled_key);
    34		}
    35	
    36		rcu_read_unlock();
    37	}
    38	
    39	void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
    40	{
    41		unsigned int type;
    42	
    43		rcu_read_lock();
    44	
    45		for (type = 0; type < __MAX_BPF_ATTACH_TYPE; type++)
  > 46			rcu_assign_pointer(cgrp->bpf.prog_effective[type],
    47				rcu_dereference(parent->bpf.prog_effective[type]));
    48	
    49		rcu_read_unlock();
    50	}
    51	
    52	/**
    53	 * __cgroup_bpf_update() - Update the pinned program of a cgroup, and
    54	 *                         propagate the change to descendants

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
