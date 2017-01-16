From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH] net/irda: fix lockdep annotation
Date: Mon, 16 Jan 2017 15:52:03 +0100
Message-ID: <CACT4Y+bBMpPjAFrCZk-KLeMhzhj-Bwh2T4SCfCXTNiF1q1cKqA@mail.gmail.com>
References: <20170116102503.23800-1-dvyukov@google.com> <201701162214.BqECKe5z%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, Dave Jones <davej@redhat.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        David Miller <davem@davemloft.net>,
        Alexander Potapenko <glider@google.com>,
        andreyknvl <andreyknvl@google.com>,
        netdev <netdev@vger.kernel.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34949 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750855AbdAPOwZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 09:52:25 -0500
Received: by mail-lf0-f49.google.com with SMTP id n124so16416076lfd.2
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 06:52:24 -0800 (PST)
In-Reply-To: <201701162214.BqECKe5z%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 3:11 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Dmitry,
>
> [auto build test WARNING on net-next/master]
> [also build test WARNING on v4.10-rc4 next-20170116]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Dmitry-Vyukov/net-irda-fix-lockdep-annotation/20170116-183405
> config: x86_64-randconfig-s2-01161850 (attached as .config)
> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All warnings (new ones prefixed by >>):
>
>    net/irda/irqueue.c: In function 'hashbin_delete':
>>> net/irda/irqueue.c:393: warning: unused variable 'depth'


Mailed v2 with a fix for the warning.

Thanks, 0-DAY!


>    At top level:
>    cc1: warning: unrecognized command line option "-Wno-maybe-uninitialized"
>
> vim +/depth +393 net/irda/irqueue.c
>
>    377
>    378
>    379  /*
>    380   * Function hashbin_delete (hashbin, free_func)
>    381   *
>    382   *    Destroy hashbin, the free_func can be a user supplied special routine
>    383   *    for deallocating this structure if it's complex. If not the user can
>    384   *    just supply kfree, which should take care of the job.
>    385   */
>    386  #ifdef CONFIG_LOCKDEP
>    387  static atomic_t hashbin_lock_depth = ATOMIC_INIT(0);
>    388  #endif
>    389  int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
>    390  {
>    391          irda_queue_t* queue;
>    392          unsigned long flags = 0;
>  > 393          int i, depth = 0;
>    394
>    395          IRDA_ASSERT(hashbin != NULL, return -1;);
>    396          IRDA_ASSERT(hashbin->magic == HB_MAGIC, return -1;);
>    397
>    398          /* Synchronize */
>    399          if ( hashbin->hb_type & HB_LOCK ) {
>    400  #ifdef CONFIG_LOCKDEP
>    401                  depth = atomic_inc_return(&hashbin_lock_depth) - 1;
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
