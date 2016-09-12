From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 2/2] errqueue: include linux/time.h
Date: Mon, 12 Sep 2016 16:09:28 -0400
Message-ID: <CAF=yD-+NT59kDn2pZks5skA2pJDakd3RGvtQZMW+87yFyY6hXg@mail.gmail.com>
References: <1473699930-58865-3-git-send-email-willemdebruijn.kernel@gmail.com>
 <201609130354.EJQifqeg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        John Stultz <john.stultz@linaro.org>,
        Brooks Moses <bmoses@google.com>,
        Willem de Bruijn <willemb@google.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201609130354.EJQifqeg%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 3:26 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Willem,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Willem-de-Bruijn/uapi-include-time-h-from-errqueue-h/20160913-020431
> config: i386-defconfig (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All errors (new ones prefixed by >>):

This error report shows that breakage can occur with applications that
include linux/errqueue.h before the libc time headers.

The libc-compat definitions in this patch set only fix compilation
when uapi headers are included after the userspace headers.

These errors indeed go away when errqueue.h is included after the
userspace time includes, as in the diff below.

For the inverse, the libc headers need additional #if __UAPI_DEF_FOO
changes, as described in include/uapli/linux/libc-compat.h. Those
changes are a noop without kernel definitions, so arguably that libc
patch should be merged before this kernel patch.

I will remove this patch set from the patchwork queue for now.

diff --git a/Documentation/networking/timestamping/txtimestamp.c
b/Documentation/networking/timestamping/txtimestamp.c
index 5df0704..f073801 100644
--- a/Documentation/networking/timestamping/txtimestamp.c
+++ b/Documentation/networking/timestamping/txtimestamp.c
@@ -37,7 +37,6 @@
 #include <error.h>
 #include <errno.h>
 #include <inttypes.h>
-#include <linux/errqueue.h>
 #include <linux/if_ether.h>
 #include <linux/net_tstamp.h>
 #include <netdb.h>
@@ -59,6 +58,7 @@
 #include <sys/time.h>
 #include <sys/types.h>
 #include <time.h>
+#include <linux/errqueue.h>
 #include <unistd.h>
