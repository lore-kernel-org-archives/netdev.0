From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 07/14] tcp: export data delivery rate
Date: Sat, 17 Sep 2016 05:38:18 +0800
Message-ID: <201609170527.89qRN0e6%fengguang.wu@intel.com>
References: <1474051743-13311-8-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:53942 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753821AbcIPVjL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 17:39:11 -0400
Content-Disposition: inline
In-Reply-To: <1474051743-13311-8-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yuchung,

[auto build test ERROR on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Neal-Cardwell/tcp-BBR-congestion-control-algorithm/20160917-025323
config: arm-simpad_defconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=arm 

All errors (new ones prefixed by >>):

   In file included from include/linux/kernel.h:142:0,
                    from include/linux/crypto.h:21,
                    from include/crypto/hash.h:16,
                    from net/ipv4/tcp.c:250:
   net/ipv4/tcp.c: In function 'tcp_get_info':
>> arch/arm/include/asm/div64.h:59:36: error: passing argument 1 of '__div64_32' from incompatible pointer type [-Werror=incompatible-pointer-types]
    #define do_div(n, base) __div64_32(&(n), base)
                                       ^
   net/ipv4/tcp.c:2794:3: note: in expansion of macro 'do_div'
      do_div(rate, intv);
      ^~~~~~
   arch/arm/include/asm/div64.h:32:24: note: expected 'uint64_t * {aka long long unsigned int *}' but argument is of type 'u32 * {aka unsigned int *}'
    static inline uint32_t __div64_32(uint64_t *n, uint32_t base)
                           ^~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/__div64_32 +59 arch/arm/include/asm/div64.h

040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  43  		: "=r" (__rem), "=r" (__res)
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  44  		: "r" (__n), "r" (__base)
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  45  		: "ip", "lr", "cc");
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  46  	*n = __res;
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  47  	return __rem;
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  48  }
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  49  #define __div64_32 __div64_32
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  50  
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  51  #if !defined(CONFIG_AEABI)
fa4adc614 include/asm-arm/div64.h      Nicolas Pitre 2006-12-06  52  
fa4adc614 include/asm-arm/div64.h      Nicolas Pitre 2006-12-06  53  /*
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  54   * In OABI configurations, some uses of the do_div function
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  55   * cause gcc to run out of registers. To work around that,
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  56   * we can force the use of the out-of-line version for
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  57   * configurations that build a OABI kernel.
fa4adc614 include/asm-arm/div64.h      Nicolas Pitre 2006-12-06  58   */
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02 @59  #define do_div(n, base) __div64_32(&(n), base)
fa4adc614 include/asm-arm/div64.h      Nicolas Pitre 2006-12-06  60  
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  61  #else
fa4adc614 include/asm-arm/div64.h      Nicolas Pitre 2006-12-06  62  
fa4adc614 include/asm-arm/div64.h      Nicolas Pitre 2006-12-06  63  /*
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  64   * gcc versions earlier than 4.0 are simply too problematic for the
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  65   * __div64_const32() code in asm-generic/div64.h. First there is
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  66   * gcc PR 15089 that tend to trig on more complex constructs, spurious
040b323b5 arch/arm/include/asm/div64.h Nicolas Pitre 2015-11-02  67   * .global __udivsi3 are inserted even if none of those symbols are

:::::: The code at line 59 was first introduced by commit
:::::: 040b323b5012b5503561ec7fe15cccd6a4bcaec2 ARM: asm/div64.h: adjust to generic codde

:::::: TO: Nicolas Pitre <nicolas.pitre@linaro.org>
:::::: CC: Nicolas Pitre <nicolas.pitre@linaro.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--vtzGhvizbBRQ85DL
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--vtzGhvizbBRQ85DL--
