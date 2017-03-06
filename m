From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 08/26] brcmsmac: make some local variables 'static const'
 to reduce stack size
Date: Mon, 6 Mar 2017 22:34:12 +0100
Message-ID: <CAK8P3a0cemG0=6jZOQEpGN+RG2Be1LM_DE7aJVX18en_i6G7=Q@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-9-arnd@arndb.de>
 <227c8e5a-fa20-0300-1cb0-1d3ef17deb19@broadcom.com> <87y3wi74y8.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        kasan-dev <kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
        Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
        Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-build-reports-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87y3wi74y8.fsf-5ukZ45wKbUHoml4zekdYB16hYfS7NtTn@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 6, 2017 at 5:19 PM, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> writes:
>
>> On 2-3-2017 17:38, Arnd Bergmann wrote:
>>> With KASAN and a couple of other patches applied, this driver is one
>>> of the few remaining ones that actually use more than 2048 bytes of
>>> kernel stack:
>>>
>>> broadcom/brcm80211/brcmsmac/phy/phy_n.c: In function 'wlc_phy_workarounds_nphy_gainctrl':
>>> broadcom/brcm80211/brcmsmac/phy/phy_n.c:16065:1: warning: the frame size of 3264 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>>> broadcom/brcm80211/brcmsmac/phy/phy_n.c: In function 'wlc_phy_workarounds_nphy':
>>> broadcom/brcm80211/brcmsmac/phy/phy_n.c:17138:1: warning: the frame size of 2864 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>>>
>>> Here, I'm reducing the stack size by marking as many local variables as
>>> 'static const' as I can without changing the actual code.
>>
>> Acked-by: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>
> Arnd, via which tree are you planning to submit these? I'm not sure
> what I should do with the wireless drivers patches from this series.

I'm not quite sure myself yet. I'd probably want the first few patches that
do most of the work get merged through Andrew's linux-mm tree once
we have come to agreement on them. The driver specific patches like
the brcmsmac ones depend on the introduction of noinline_for_kasan
or noinline_if_stackbloat and could either go in along with the first
set, or as a follow-up through the normal maintainer trees.

       Arnd
