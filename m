From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net] net: nsid cannot be allocated for a dead netns
Date: Wed, 16 Nov 2016 18:23:06 +0800
Message-ID: <201611161852.okhcoalA%fengguang.wu@intel.com>
References: <1479285671-1298-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Cc: kbuild-all@01.org, avagin@gmail.com, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:61141 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752308AbcKPKXO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 05:23:14 -0500
Content-Disposition: inline
In-Reply-To: <1479285671-1298-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Nicolas,

[auto build test ERROR on net/master]

url:    https://github.com/0day-ci/linux/commits/Nicolas-Dichtel/net-nsid-cannot-be-allocated-for-a-dead-netns/20161116-164739
config: sparc-defconfig (attached as .config)
compiler: sparc-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sparc 

All error/warnings (new ones prefixed by >>):

   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/linux/list.h:4,
                    from include/linux/timer.h:4,
                    from include/linux/workqueue.h:8,
                    from net/core/net_namespace.c:3:
   net/core/net_namespace.c: In function 'alloc_netid':
>> arch/sparc/include/asm/atomic_32.h:32:48: error: invalid type argument of '->' (have 'atomic_t {aka struct <anonymous>}')
    #define atomic_read(v)          ACCESS_ONCE((v)->counter)
                                                   ^
   include/linux/compiler.h:545:25: note: in definition of macro '__ACCESS_ONCE'
      __maybe_unused typeof(x) __var = (__force typeof(x)) 0; \
                            ^
>> arch/sparc/include/asm/atomic_32.h:32:33: note: in expansion of macro 'ACCESS_ONCE'
    #define atomic_read(v)          ACCESS_ONCE((v)->counter)
                                    ^~~~~~~~~~~
   net/core/net_namespace.c:162:37: note: in expansion of macro 'atomic_read'
     if (!atomic_read(&net->count) || !&atomic_read(peer->count))
                                        ^~~~~~~~~~~
>> arch/sparc/include/asm/atomic_32.h:32:48: error: invalid type argument of '->' (have 'atomic_t {aka struct <anonymous>}')
    #define atomic_read(v)          ACCESS_ONCE((v)->counter)
                                                   ^
   include/linux/compiler.h:545:52: note: in definition of macro '__ACCESS_ONCE'
      __maybe_unused typeof(x) __var = (__force typeof(x)) 0; \
                                                       ^
>> arch/sparc/include/asm/atomic_32.h:32:33: note: in expansion of macro 'ACCESS_ONCE'
    #define atomic_read(v)          ACCESS_ONCE((v)->counter)
                                    ^~~~~~~~~~~
   net/core/net_namespace.c:162:37: note: in expansion of macro 'atomic_read'
     if (!atomic_read(&net->count) || !&atomic_read(peer->count))
                                        ^~~~~~~~~~~
>> arch/sparc/include/asm/atomic_32.h:32:48: error: invalid type argument of '->' (have 'atomic_t {aka struct <anonymous>}')
    #define atomic_read(v)          ACCESS_ONCE((v)->counter)
                                                   ^
   include/linux/compiler.h:546:19: note: in definition of macro '__ACCESS_ONCE'
     (volatile typeof(x) *)&(x); })
                      ^
>> arch/sparc/include/asm/atomic_32.h:32:33: note: in expansion of macro 'ACCESS_ONCE'
    #define atomic_read(v)          ACCESS_ONCE((v)->counter)
                                    ^~~~~~~~~~~
   net/core/net_namespace.c:162:37: note: in expansion of macro 'atomic_read'
     if (!atomic_read(&net->count) || !&atomic_read(peer->count))
                                        ^~~~~~~~~~~
>> arch/sparc/include/asm/atomic_32.h:32:48: error: invalid type argument of '->' (have 'atomic_t {aka struct <anonymous>}')
    #define atomic_read(v)          ACCESS_ONCE((v)->counter)
                                                   ^
   include/linux/compiler.h:546:26: note: in definition of macro '__ACCESS_ONCE'
     (volatile typeof(x) *)&(x); })
                             ^
>> arch/sparc/include/asm/atomic_32.h:32:33: note: in expansion of macro 'ACCESS_ONCE'
    #define atomic_read(v)          ACCESS_ONCE((v)->counter)
                                    ^~~~~~~~~~~
   net/core/net_namespace.c:162:37: note: in expansion of macro 'atomic_read'
     if (!atomic_read(&net->count) || !&atomic_read(peer->count))
                                        ^~~~~~~~~~~

vim +32 arch/sparc/include/asm/atomic_32.h

d550bbd4 arch/sparc/include/asm/atomic_32.h David Howells   2012-03-28  16  #include <asm/cmpxchg.h>
56d36489 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2014-03-13  17  #include <asm/barrier.h>
aea1181b arch/sparc/include/asm/atomic_32.h Sam Ravnborg    2011-12-27  18  #include <asm-generic/atomic64.h>
aea1181b arch/sparc/include/asm/atomic_32.h Sam Ravnborg    2011-12-27  19  
f5e706ad include/asm-sparc/atomic_32.h      Sam Ravnborg    2008-07-17  20  #define ATOMIC_INIT(i)  { (i) }
f5e706ad include/asm-sparc/atomic_32.h      Sam Ravnborg    2008-07-17  21  
4f3316c2 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2014-03-26  22  int atomic_add_return(int, atomic_t *);
3a1adb23 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2016-04-18  23  int atomic_fetch_add(int, atomic_t *);
3a1adb23 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2016-04-18  24  int atomic_fetch_and(int, atomic_t *);
3a1adb23 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2016-04-18  25  int atomic_fetch_or(int, atomic_t *);
3a1adb23 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2016-04-18  26  int atomic_fetch_xor(int, atomic_t *);
f05a6865 arch/sparc/include/asm/atomic_32.h Sam Ravnborg    2014-05-16  27  int atomic_cmpxchg(atomic_t *, int, int);
1a17fdc4 arch/sparc/include/asm/atomic_32.h Andreas Larsson 2014-11-05  28  int atomic_xchg(atomic_t *, int);
f05a6865 arch/sparc/include/asm/atomic_32.h Sam Ravnborg    2014-05-16  29  int __atomic_add_unless(atomic_t *, int, int);
f05a6865 arch/sparc/include/asm/atomic_32.h Sam Ravnborg    2014-05-16  30  void atomic_set(atomic_t *, int);
f5e706ad include/asm-sparc/atomic_32.h      Sam Ravnborg    2008-07-17  31  
2291059c arch/sparc/include/asm/atomic_32.h Pranith Kumar   2014-09-23 @32  #define atomic_read(v)          ACCESS_ONCE((v)->counter)
f5e706ad include/asm-sparc/atomic_32.h      Sam Ravnborg    2008-07-17  33  
4f3316c2 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2014-03-26  34  #define atomic_add(i, v)	((void)atomic_add_return( (int)(i), (v)))
4f3316c2 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2014-03-26  35  #define atomic_sub(i, v)	((void)atomic_add_return(-(int)(i), (v)))
4f3316c2 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2014-03-26  36  #define atomic_inc(v)		((void)atomic_add_return(        1, (v)))
4f3316c2 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2014-03-26  37  #define atomic_dec(v)		((void)atomic_add_return(       -1, (v)))
f5e706ad include/asm-sparc/atomic_32.h      Sam Ravnborg    2008-07-17  38  
3a1adb23 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2016-04-18  39  #define atomic_and(i, v)	((void)atomic_fetch_and((i), (v)))
3a1adb23 arch/sparc/include/asm/atomic_32.h Peter Zijlstra  2016-04-18  40  #define atomic_or(i, v)		((void)atomic_fetch_or((i), (v)))

:::::: The code at line 32 was first introduced by commit
:::::: 2291059c852706c6f5ffb400366042b7625066cd locking,arch: Use ACCESS_ONCE() instead of cast to volatile in atomic_read()

:::::: TO: Pranith Kumar <bobby.prani@gmail.com>
:::::: CC: Ingo Molnar <mingo@kernel.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--PNTmBPCT7hxwcZjr
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--PNTmBPCT7hxwcZjr--
