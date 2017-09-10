From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Division by zero on UP (was: Re: netfilter: nat: use keyed locks)
Date: Sun, 10 Sep 2017 13:34:49 +0200
Message-ID: <CAMuHMdWnzu9v_arbovZV46kjrTTpVa-GQFKx+QzxU2Kpnt5itA@mail.gmail.com>
References: <CAMuHMdVwp1njkMYo-y8FZHWNWW6wtN2LYVC=9-mbcF-omDaztw@mail.gmail.com>
 <20170910112126.GB25977@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170910112126.GB25977@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Sun, Sep 10, 2017 at 1:21 PM, Florian Westphal <fw@strlen.de> wrote:
> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>> >                 srchash =3D hash_by_src(net,
>> >                                       &ct->tuplehash[IP_CT_DIR_ORIGINA=
L].tuple);
>> > -               spin_lock_bh(&nf_nat_lock);
>> > +               lock =3D &nf_nat_locks[srchash % ARRAY_SIZE(nf_nat_loc=
ks)];
>> > +               spin_lock_bh(lock);
>>
>> If no spinlock debugging options (CONFIG_GENERIC_LOCKBREAK,
>> CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_LOCK_ALLOC) are enabled on a UP plat=
form
>> (e.g. m68k defconfig), arch_spinlock_t is an empty struct, and thus
>> ARRAY_SIZE(nf_nat_locks)] is zero, leading to:
>>
>>     net/netfilter/nf_nat_core.c: In function =E2=80=98nf_nat_setup_info=
=E2=80=99:
>>     net/netfilter/nf_nat_core.c:432: warning: division by zero
>
> Gah. Sorry.  This is the 2nd time I add such a bug :(
>
> Can you send a patch?  It should be enough to use CONNTRACK_LOCKS
> instead of ARRAY_SIZE(nf_nat_locks) to avoid this problem.
>
> Otherwise I will take care of this next thing monday morning.

Thanks for the suggestion, will send a patch RSN.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
