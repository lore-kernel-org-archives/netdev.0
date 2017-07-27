From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 2/2] bnxt_en: define sriov_lock unconditionally
Date: Thu, 27 Jul 2017 09:48:48 +0200
Message-ID: <CAK8P3a1hiEwZrPoEsCXbATM2RZPKPnhkMFjyX0t6Yee+px9afQ@mail.gmail.com>
References: <20170725153046.44726-1-arnd@arndb.de> <20170725153046.44726-2-arnd@arndb.de>
 <CACKFLimnZx7v9jV7v27XMP62BWG577D8=zkTijQYa6Pi1Ct7yA@mail.gmail.com>
 <CAK8P3a3UBfg6=GJ5UKEENnN-qoFuxaO4yo2Lqy65gN0zP4Nw-w@mail.gmail.com>
 <CAKvpyk3hyoAj0w9v1ZDfBs=8s4c=3kbDT8ZpDEUTb1yJnRvzuA@mail.gmail.com> <CAK8P3a2crDS+D4C0cOBbr+RpcgH=YqotPovfNZVsXR0HbW382g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Michael Chan <michael.chan@broadcom.com>,
        "David S. Miller" <davem@davemloft.net>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Sathya Perla <sathya.perla@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a2crDS+D4C0cOBbr+RpcgH=YqotPovfNZVsXR0HbW382g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2017 at 3:18 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wed, Jul 26, 2017 at 12:54 PM, Sathya Perla
> <sathya.perla@broadcom.com> wrote:
>> On Wed, Jul 26, 2017 at 2:35 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> [...]
>>>> Sathya already sent 3 patches to fix some of these issues.  But I need
>>>> to rework one of his patch and resend.
>>>
>>> Ok, thanks. I just ran into one more issue, and don't know if that's included
>>> as well. If not, please also add the patch below (or fold it into the one
>>> that adds the switchdev dependency to the ethernet driver):
>>>
>>> 8<----------
>>> Subject: [PATCH] RDMA/bnxt_re: add NET_SWITCHDEV dependency
>>>
>>> The rdma side of BNXT enables the ethernet driver and has a list
>>> of its dependencies. However, the ethernet driver now also depends
>>> on NET_SWITCHDEV, so we have to add that dependency for both:
>>
>> Arnd, after the patch "bnxt_en: use SWITCHDEV_SET_OPS() for setting
>> vf_rep_switchdev_ops" the bnxt_en driver doesn't need an explicit
>> NET_SWITCHDEV dependency. So, the bnxt_re driver shouldn't need one
>> either. Are you still seeing the bnxt_re issue even after pulling the
>> above patch??
>
> I think that's fine then. I missed that patch when it went in, so I only
> needed the add-on since I still had my own earlier patch. I'll drop both
> from my test tree now, and will let you know in case something else
> remains.

On today's linux-next:

drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.o: In function `bnxt_dl_register':
bnxt_vfr.c:(.text+0x1440): undefined reference to `devlink_alloc'
bnxt_vfr.c:(.text+0x14c0): undefined reference to `devlink_register'
bnxt_vfr.c:(.text+0x14e0): undefined reference to `devlink_free'
drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.o: In function `bnxt_dl_unregister':
bnxt_vfr.c:(.text+0x1534): undefined reference to `devlink_unregister'
bnxt_vfr.c:(.text+0x153c): undefined reference to `devlink_free'

I think you are just missing a "depends on MAY_USE_DEVLINK"
in INFINIBAND_BNXT_RE, which uses 'select BNXT'.

This is a tricky corner case for Kconfig, where the MAY_USE_DEVLINK
dependency is silently ignored for BNXT as long as MAY_USE_DEVLINK
is not "=n".

       Arnd
