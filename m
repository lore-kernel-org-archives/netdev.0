From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] ethtool: do not vzalloc(0) on registers dump
Date: Thu, 2 Feb 2017 20:22:24 +0800
Message-ID: <201702022032.ou4IF2Az%fengguang.wu@intel.com>
References: <1486035113-2305-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3MwIy2ne0vdjdPXF"
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        Ben Hutchings <ben@decadent.org.uk>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52667 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751626AbdBBMXC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 07:23:02 -0500
Content-Disposition: inline
In-Reply-To: <1486035113-2305-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Stanislaw,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.10-rc6 next-20170202]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Stanislaw-Gruszka/ethtool-do-not-vzalloc-0-on-registers-dump/20170202-194352
config: cris-etrax-100lx_v2_defconfig (attached as .config)
compiler: cris-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=cris 

Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings

All warnings (new ones prefixed by >>):

   net/core/ethtool.c: In function 'ethtool_get_feature_mask':
   net/core/ethtool.c:311:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from include/linux/uaccess.h:5:0,
                    from include/net/checksum.h:25,
                    from include/linux/skbuff.h:31,
                    from include/linux/if_ether.h:23,
                    from include/uapi/linux/ethtool.h:18,
                    from include/linux/ethtool.h:17,
                    from net/core/ethtool.c:18:
   net/core/ethtool.c: In function 'ethtool_get_regs':
>> arch/cris/include/asm/uaccess.h:380:10: warning: 'regbuf' may be used uninitialized in this function [-Wmaybe-uninitialized]
      return __copy_user(to, from, n);
             ^~~~~~~~~~~~~~~~~~~~~~~~
   net/core/ethtool.c:1395:8: note: 'regbuf' was declared here
     void *regbuf;
           ^~~~~~

vim +/regbuf +380 arch/cris/include/asm/uaccess.h

eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  364  		memset(to, 0, n);
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  365  		return n;
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  366  	}
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  367  	if (__builtin_constant_p(n))
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  368  		return __constant_copy_from_user(to, from, n);
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  369  	else
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  370  		return __copy_user_zeroing(to, from, n);
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  371  }
^1da177e4 include/asm-cris/uaccess.h      Linus Torvalds 2005-04-16  372  
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  373  static inline size_t copy_to_user(void __user *to, const void *from, size_t n)
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  374  {
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  375  	if (unlikely(!access_ok(VERIFY_WRITE, to, n)))
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  376  		return n;
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  377  	if (__builtin_constant_p(n))
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  378  		return __constant_copy_to_user(to, from, n);
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  379  	else
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18 @380  		return __copy_user(to, from, n);
eb47e0293 arch/cris/include/asm/uaccess.h Al Viro        2016-08-18  381  }
^1da177e4 include/asm-cris/uaccess.h      Linus Torvalds 2005-04-16  382  
^1da177e4 include/asm-cris/uaccess.h      Linus Torvalds 2005-04-16  383  /* We let the __ versions of copy_from/to_user inline, because they're often
^1da177e4 include/asm-cris/uaccess.h      Linus Torvalds 2005-04-16  384   * used in fast paths and have only a small space overhead.
^1da177e4 include/asm-cris/uaccess.h      Linus Torvalds 2005-04-16  385   */
^1da177e4 include/asm-cris/uaccess.h      Linus Torvalds 2005-04-16  386  
d9b5444ee include/asm-cris/uaccess.h      Adrian Bunk    2005-11-07  387  static inline unsigned long
07f2402b4 include/asm-cris/uaccess.h      Jesper Nilsson 2008-03-04  388  __generic_copy_from_user_nocheck(void *to, const void __user *from,

:::::: The code at line 380 was first introduced by commit
:::::: eb47e0293baaa3044022059f1fa9ff474bfe35cb cris: buggered copy_from_user/copy_to_user/clear_user

:::::: TO: Al Viro <viro@zeniv.linux.org.uk>
:::::: CC: Al Viro <viro@zeniv.linux.org.uk>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--3MwIy2ne0vdjdPXF
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
8fsFJnspNiyjMD416P//AQhwUdbofgAA

--3MwIy2ne0vdjdPXF--
