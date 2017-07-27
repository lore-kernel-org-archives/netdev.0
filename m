From: Sathya Perla <sathya.perla@broadcom.com>
Subject: Re: [PATCH net-next 2/2] bnxt_en: define sriov_lock unconditionally
Date: Thu, 27 Jul 2017 14:30:10 +0530
Message-ID: <CAKvpyk1BYhLKPRcATLx58ACA-+SpjbNXKVuvedpf7wdAhONZww@mail.gmail.com>
References: <20170725153046.44726-1-arnd@arndb.de> <20170725153046.44726-2-arnd@arndb.de>
 <CACKFLimnZx7v9jV7v27XMP62BWG577D8=zkTijQYa6Pi1Ct7yA@mail.gmail.com>
 <CAK8P3a3UBfg6=GJ5UKEENnN-qoFuxaO4yo2Lqy65gN0zP4Nw-w@mail.gmail.com>
 <CAKvpyk3hyoAj0w9v1ZDfBs=8s4c=3kbDT8ZpDEUTb1yJnRvzuA@mail.gmail.com>
 <CAK8P3a2crDS+D4C0cOBbr+RpcgH=YqotPovfNZVsXR0HbW382g@mail.gmail.com> <CAK8P3a1hiEwZrPoEsCXbATM2RZPKPnhkMFjyX0t6Yee+px9afQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Michael Chan <michael.chan@broadcom.com>,
        "David S. Miller" <davem@davemloft.net>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a1hiEwZrPoEsCXbATM2RZPKPnhkMFjyX0t6Yee+px9afQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27, 2017 at 1:18 PM, Arnd Bergmann <arnd@arndb.de> wrote:
[...]
>
> On today's linux-next:
>
> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.o: In function `bnxt_dl_register':
> bnxt_vfr.c:(.text+0x1440): undefined reference to `devlink_alloc'
> bnxt_vfr.c:(.text+0x14c0): undefined reference to `devlink_register'
> bnxt_vfr.c:(.text+0x14e0): undefined reference to `devlink_free'
> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.o: In function `bnxt_dl_unregister':
> bnxt_vfr.c:(.text+0x1534): undefined reference to `devlink_unregister'
> bnxt_vfr.c:(.text+0x153c): undefined reference to `devlink_free'
>
> I think you are just missing a "depends on MAY_USE_DEVLINK"
> in INFINIBAND_BNXT_RE, which uses 'select BNXT'.
>
> This is a tricky corner case for Kconfig, where the MAY_USE_DEVLINK
> dependency is silently ignored for BNXT as long as MAY_USE_DEVLINK
> is not "=n".

Can you pls share your .config so that I can reproduce this issue and
ensure that my fix really works...
