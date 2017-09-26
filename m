From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 8/9] netlink: fix nla_put_{u8,u16,u32} for KASAN
Date: Mon, 25 Sep 2017 20:19:51 -0700 (PDT)
Message-ID: <20170925.201951.1512252559012166718.davem@davemloft.net>
References: <20170922212930.620249-1-arnd@arndb.de>
        <20170922212930.620249-9-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchehab@kernel.org, jiri@resnulli.us, arend.vanspriel@broadcom.com,
        kvalo@codeaurora.org, aryabinin@virtuozzo.com, glider@google.com,
        dvyukov@google.com, yamada.masahiro@socionext.com, mmarek@suse.com,
        akpm@linux-foundation.org, keescook@chromium.org,
        geert@linux-m68k.org, gregkh@linuxfoundation.org,
        linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, kasan-dev@googlegroups.com,
        linux-kbuild@vger.kernel.org, jakub@gcc.gnu.org,
        marxin@gcc.gnu.org, stable@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922212930.620249-9-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 22 Sep 2017 23:29:19 +0200

> When CONFIG_KASAN is enabled, the "--param asan-stack=1" causes rather large
> stack frames in some functions. This goes unnoticed normally because
> CONFIG_FRAME_WARN is disabled with CONFIG_KASAN by default as of commit
> 3f181b4d8652 ("lib/Kconfig.debug: disable -Wframe-larger-than warnings with
> KASAN=y").
> 
> The kernelci.org build bot however has the warning enabled and that led
> me to investigate it a little further, as every build produces these warnings:
> 
> net/wireless/nl80211.c:4389:1: warning: the frame size of 2240 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> net/wireless/nl80211.c:1895:1: warning: the frame size of 3776 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> net/wireless/nl80211.c:1410:1: warning: the frame size of 2208 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> net/bridge/br_netlink.c:1282:1: warning: the frame size of 2544 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> 
> Most of this problem is now solved in gcc-8, which can consolidate
> the stack slots for the inline function arguments. On older compilers
> we can add a workaround by declaring a local variable in each function
> to pass the inline function argument.
> 
> Cc: stable@vger.kernel.org
> Link: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
