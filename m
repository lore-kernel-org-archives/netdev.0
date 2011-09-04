From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: linux-next: Tree for Aug 26 (git-bisect: [0856a30] Scm: Remove
 unnecessary pid & credential references in Unix socket's send and receive path)
Date: Sun, 4 Sep 2011 12:43:49 +0200
Message-ID: <CA+icZUUmCSP6iGj1Ni_Gd+9xa=_+XVDrYajCZcuh3iwRYrvncw@mail.gmail.com>
References: <CA+icZUXOnoG07Z8-AAUNqvuJmq6-OY1_dTzkxsBOLczoNYYGEw@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	jirislaby@gmail.com, David Miller <davem@davemloft.net>,
	"Yan, Zheng" <zheng.z.yan@intel.com>, Valdis.Kletnieks@vt.edu,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>, tim.c.chen@linux.intel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CA+icZUXOnoG07Z8-AAUNqvuJmq6-OY1_dTzkxsBOLczoNYYGEw@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 2, 2011 at 11:43 PM, Sedat Dilek <sedat.dilek@googlemail.co=
m> wrote:
> On Fri, Aug 26, 2011 at 7:00 AM, Stephen Rothwell <sfr@canb.auug.org.=
au> wrote:
>> Hi all,
>>
>> The powerpc allyesconfig build still fails today.
>>
>> Changes since 20110825:
>>
>> The slave-dma tree gained a conflict against Linus' tree.
>>
>> I have reverted the x86/spinlocks branch from the tip tree for today=
=2E
>>
>> The ptrace tree lost its build failure.
>>
>> The xen tree lost its conflict since I reveretd the version of the s=
ame
>> patches in the tip tree..
>>
>> The tty tree still has its build failure but I applied a supplied te=
st
>> patch for it.
>>
>> The staging tree lost its build failures and gained a conflict again=
st
>> the net tree.
>>
>> The moduleh tree lost a conflict.
>>
>> The akpm tree lost its build failure.
>>
>> --------------------------------------------------------------------=
--------
>>
>
> Hi,
>
> I saw diverse strange kernel-panics letting my notebook blink and
> scream a high-frequency tone, really ugly.
>
> My last good linux-next (l-n) kernel was next-20110818 and the next
> l-n kernel in series which I built and was broken: next-20110826.
> ( BTW, 29/31 Aug are broken too. )
>
> For the correctness I built 22/23/24/25 Aug which were all good.
> As usual when I do once a year a git-bisect... its the last step of 1=
2
> steps in total (see git-bisect_visualize.txt and
> git-bisect_view-stat.txt).
>
> I was irritated by using next-20110825 and next-20110826 as git-bisec=
t
> good and bad, as the first offered commit-id pointed me to
> 3.1-rc1-665-gec5efe7, but I was sure the culprit is definitely
> v3.1-rc3+ and furthermore I got no info how many revisions have to be
> walked through. So, I cancelled this run.
>
> Next thought was to do a git format-patch using above mentionned
> commit-ids (of the tags): 819 single patches.
> I took the commit-ids of 0001 (good) and 0818 (bad) - 0819 was
> linux-specific mumbo-jumbo.
>
> Jiri has reported a similiar breakage in [2] and returning CULPRIT
> commit [1] helped him.
> ( This git-bisect steal a whole Friday. Anyway, it's good to see we
> isolated the "bad" patch. )
>
> As a personal conclusion, trust more git-bisect...
> It does not hurt to NOT turn off brain my looking over the single
> patches, there were lots of staging, arm, powerpc which could be
> surely ignored, but in the end you are wiser - 12 steps are faster
> than reverting xxx single commits on spec.
>
> - Sedat -
>
> [1] http://git.us.kernel.org/?p=3Dlinux/kernel/git/next/linux-next.gi=
t;a=3Dcommit;h=3D0856a304091b33a8e8f9f9c98e776f425af2b625
> [2] http://lkml.org/lkml/2011/9/1/332
> [3] http://www.kernel.org/pub/software/scm/git/docs/git-bisect.html
> [4] http://www.kernel.org/pub/software/scm/git/docs/user-manual.html#=
using-bisect
>
> P.S.: Used 0001 (good) and 0818 (bad) for git-bisect
>
> $ head -5 0001-target-Change-TCM_NON_EXISTENT_LUN-response-to-ASC-L.p=
atch
> 0818-Fixes-the-deadlock-when-inserting-and-removing-the-d.patch
> =3D=3D> 0001-target-Change-TCM_NON_EXISTENT_LUN-response-to-ASC-L.pat=
ch <=3D=3D
> From eb39d34004888afcc0a44d9c36383cd69fa3b3b9 Mon Sep 17 00:00:00 200=
1
> From: Nicholas Bellinger <nab@linux-iscsi.org>
> Date: Tue, 26 Jul 2011 16:59:00 -0700
> Subject: [PATCH 001/819] target: Change TCM_NON_EXISTENT_LUN response=
 to
> =C2=A0ASC=3DLOGICAL UNIT NOT SUPPORTED
>
> =3D=3D> 0818-Fixes-the-deadlock-when-inserting-and-removing-the-d.pat=
ch <=3D=3D
> From 9b198e560524e3fe341cd2ae478a1cdf2f57fc33 Mon Sep 17 00:00:00 200=
1
> From: Clifton Barnes <cabarnes@indesign-llc.com>
> Date: Thu, 25 Aug 2011 09:47:59 +1000
> Subject: [PATCH 818/819] Fixes the deadlock when inserting and removi=
ng the
> =C2=A0ds2780.
>

Issue fixed, see "[PATCH -next v2] unix stream: Fix use-after-free cras=
hes" [1].

- Sedat -

[1] http://marc.info/?l=3Dlinux-netdev&m=3D131511507007022&w=3D2
