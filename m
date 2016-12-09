From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: deadlock on genl_mutex
Date: Thu, 8 Dec 2016 16:13:50 -0800
Message-ID: <CAM_iQpW-KNT4iZPwtHMzzBxvPVvvn6+9OfJMcUjBOXS_zJ_NEA@mail.gmail.com>
References: <CACT4Y+ZdSNVhF2MH0=t=kBUrgNSSnCSO5uwnnc5c0KNLG+VNFQ@mail.gmail.com>
 <CANn89iJ1G4e655RnfcGK9RwmSSb2L=ZBSq9e2gpHVNmkUOYUxg@mail.gmail.com>
 <0227d7e83cc5ac0a192d1ba0fee61413@codeaurora.org> <CACT4Y+auHN0Rdu2Hepk6DNFmz1K2XSA6s18PC=KZiHdoMG845Q@mail.gmail.com>
 <CACT4Y+Zy82UAJ55VbPbVadUM92ZSx1VJCFPdhhcmj53uxZ5PXQ@mail.gmail.com> <CACT4Y+YaUL8F2L0h1VG3QZP=gSC4NJ=NOTG_dH5Awz=FOd1EVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Florian Westphal <fw@strlen.de>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Richard Guy Briggs <rgb@redhat.com>,
        netdev-owner@vger.kernel.org
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+YaUL8F2L0h1VG3QZP=gSC4NJ=NOTG_dH5Awz=FOd1EVg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 8, 2016 at 10:02 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Chain exists of:
>  Possible unsafe locking scenario:
>
>        CPU0                    CPU1
>        ----                    ----
>   lock(nlk->cb_mutex);
>                                lock(&table[i].mutex);
>                                lock(nlk->cb_mutex);
>   lock(genl_mutex);

Similar to the unix bindlock, this one looks false positive to me too.
