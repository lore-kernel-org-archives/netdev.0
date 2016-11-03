From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/netlink: another global-out-of-bounds in genl_family_rcv_msg/validate_nla
Date: Fri, 4 Nov 2016 00:34:58 +0100
Message-ID: <CAAeHK+zn=m53SWobPoDy1h1YozHXs1ZrEkCTMdAnrcMEtaOrJw@mail.gmail.com>
References: <CAAeHK+yzXs-JTNpEuEWyHZpJvfWHb5poP--M-vYTs-oQhQFdBQ@mail.gmail.com>
 <CAM_iQpVy+pEN23mtdeot5ReS+62L2bf=UX27WGDNVTnc-nK8Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        Florian Westphal <fw@strlen.de>,
        netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVy+pEN23mtdeot5ReS+62L2bf=UX27WGDNVTnc-nK8Qg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 4, 2016 at 12:22 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Nov 3, 2016 at 4:04 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while running the syzkaller fuzzer:
>>
>> BUG: KASAN: global-out-of-bounds in validate_nla+0x49b/0x4e0 at addr
>> ffffffff84452de0
>> Read of size 2 by task syz-executor/19055
>> Address belongs to variable ip_vs_cmd_policy+0x20/0x40
>
> LOL, seems a typo
>
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index c3c809b..a6e44ef 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2845,7 +2845,7 @@ static struct genl_family ip_vs_genl_family = {
>         .hdrsize        = 0,
>         .name           = IPVS_GENL_NAME,
>         .version        = IPVS_GENL_VERSION,
> -       .maxattr        = IPVS_CMD_MAX,
> +       .maxattr        = IPVS_CMD_ATTR_MAX,
>         .netnsok        = true,         /* Make ipvsadm to work on netns */
>  };

This fixes the issue for me.

Tested-by: Andrey Konovalov <andreyknvl@google.com>

Thanks again!
