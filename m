From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 4/6] bpf: track if the bpf program was loaded
 with SYS_ADMIN capabilities
Date: Thu, 27 Apr 2017 18:09:14 +0800
Message-ID: <201704271854.7PplYIu7%fengguang.wu@intel.com>
References: <20170426182419.14574-5-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.com, jbenc@redhat.com, aconole@bytheb.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43315 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751458AbdD0KJW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 06:09:22 -0400
Content-Disposition: inline
In-Reply-To: <20170426182419.14574-5-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Hannes-Frederic-Sowa/bpf-list-all-loaded-ebpf-programs-in-proc-bpf-programs/20170427-090839
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:264:8: sparse: attribute 'no_sanitize_address': unknown attribute
   lib/test_bpf.c:407:29: sparse: subtraction of functions? Share your drugs
   lib/test_bpf.c:418:29: sparse: subtraction of functions? Share your drugs
>> lib/test_bpf.c:5613:36: sparse: not enough arguments for function bpf_prog_alloc
   lib/test_bpf.c: In function 'generate_filter':
   lib/test_bpf.c:5613:8: error: too few arguments to function 'bpf_prog_alloc'
      fp = bpf_prog_alloc(bpf_prog_size(flen), 0);
           ^~~~~~~~~~~~~~
   In file included from lib/test_bpf.c:20:0:
   include/linux/filter.h:619:18: note: declared here
    struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags,
                     ^~~~~~~~~~~~~~

vim +5613 lib/test_bpf.c

10f18e0ba Daniel Borkmann    2014-05-23  5597  				/* Verifier didn't reject the test that's
10f18e0ba Daniel Borkmann    2014-05-23  5598  				 * bad enough, just return!
10f18e0ba Daniel Borkmann    2014-05-23  5599  				 */
10f18e0ba Daniel Borkmann    2014-05-23  5600  				*err = -EINVAL;
10f18e0ba Daniel Borkmann    2014-05-23  5601  				return NULL;
10f18e0ba Daniel Borkmann    2014-05-23  5602  			}
10f18e0ba Daniel Borkmann    2014-05-23  5603  		}
10f18e0ba Daniel Borkmann    2014-05-23  5604  		/* We don't expect to fail. */
10f18e0ba Daniel Borkmann    2014-05-23  5605  		if (*err) {
10f18e0ba Daniel Borkmann    2014-05-23  5606  			pr_cont("FAIL to attach err=%d len=%d\n",
10f18e0ba Daniel Borkmann    2014-05-23  5607  				*err, fprog.len);
10f18e0ba Daniel Borkmann    2014-05-23  5608  			return NULL;
64a8946b4 Alexei Starovoitov 2014-05-08  5609  		}
10f18e0ba Daniel Borkmann    2014-05-23  5610  		break;
10f18e0ba Daniel Borkmann    2014-05-23  5611  
10f18e0ba Daniel Borkmann    2014-05-23  5612  	case INTERNAL:
60a3b2253 Daniel Borkmann    2014-09-02 @5613  		fp = bpf_prog_alloc(bpf_prog_size(flen), 0);
10f18e0ba Daniel Borkmann    2014-05-23  5614  		if (fp == NULL) {
10f18e0ba Daniel Borkmann    2014-05-23  5615  			pr_cont("UNEXPECTED_FAIL no memory left\n");
10f18e0ba Daniel Borkmann    2014-05-23  5616  			*err = -ENOMEM;
10f18e0ba Daniel Borkmann    2014-05-23  5617  			return NULL;
10f18e0ba Daniel Borkmann    2014-05-23  5618  		}
10f18e0ba Daniel Borkmann    2014-05-23  5619  
10f18e0ba Daniel Borkmann    2014-05-23  5620  		fp->len = flen;
4962fa10f Daniel Borkmann    2015-07-30  5621  		/* Type doesn't really matter here as long as it's not unspec. */

:::::: The code at line 5613 was first introduced by commit
:::::: 60a3b2253c413cf601783b070507d7dd6620c954 net: bpf: make eBPF interpreter images read-only

:::::: TO: Daniel Borkmann <dborkman@redhat.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
