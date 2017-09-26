From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 7/9] rocker: fix rocker_tlv_put_* functions for KASAN
Date: Mon, 25 Sep 2017 20:19:44 -0700 (PDT)
Message-ID: <20170925.201944.383866196624108211.davem@davemloft.net>
References: <20170922212930.620249-1-arnd@arndb.de>
        <20170922212930.620249-8-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, mchehab@kernel.org, arend.vanspriel@broadcom.com,
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
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20170922212930.620249-8-arnd@arndb.de>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 22 Sep 2017 23:29:18 +0200

> Inlining these functions creates lots of stack variables that each take
> 64 bytes when KASAN is enabled, leading to this warning about potential
> stack overflow:
> 
> drivers/net/ethernet/rocker/rocker_ofdpa.c: In function 'ofdpa_cmd_flow_tbl_add':
> drivers/net/ethernet/rocker/rocker_ofdpa.c:621:1: error: the frame size of 2752 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> 
> gcc-8 can now consolidate the stack slots itself, but on older versions
> we get the same behavior by using a temporary variable that holds a
> copy of the inline function argument.
> 
> Cc: stable@vger.kernel.org
> Link: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
