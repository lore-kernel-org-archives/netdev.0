From: Joe Perches <joe@perches.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Fri, 04 Dec 2015 09:03:09 -0800
Message-ID: <1449248589.8611.10.camel@perches.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
	 <20151203130525.GB4164@mrl.redhat.com>
	 <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
	 <CANn89iKEv-q6EFi1eX+Hk_2+jNfZ0ayUqUn_Fh1U7RTs9xjdXg@mail.gmail.com>
	 <CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
	 <CANn89i+d=mTJ-hAhhgPXsZPGAkQdECxRdbkeRLfozRq8i9Ms+g@mail.gmail.com>
	 <CACT4Y+YJe-OJj9q1Kr5-_ApDt1UBKLjTRxhP62EHtEAwZt5vXw@mail.gmail.com>
	 <f7twpsvgyar.fsf@aconole.bos.csb> <566098BD.6010803@akamai.com>
	 <1449172984.12092.0.camel@perches.com> <5660A1A7.3080301@akamai.com>
	 <1449174246.12092.8.camel@perches.com> <5660A951.4000808@akamai.com>
	 <1449175884.17296.2.camel@perches.com>
	 <CACT4Y+btkVJBtXkp0QAJhdoK_5TeVJ97GU_wOrMsPNG3E98vaQ@mail.gmail.com>
	 <5661C3B8.2030902@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aaron Conole <aconole@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Jason Baron <jbaron@akamai.com>, Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5661C3B8.2030902@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-12-04 at 11:47 -0500, Jason Baron wrote:
> When DYNAMIC_DEBUG is enabled we have this wrapper from
> include/linux/dynamic_debug.h:
>=20
> if (unlikely(descriptor.flags & _DPRINTK_FLAGS_PRINT))
> 	<do debug stuff>
>=20
> So the compiler is not emitting the side-effects in this
> case.

Huh? =A0Do I misunderstand what you are writing?

You are testing a variable that is not generally set
so the call is not being performed in the general case,
but the compiler can not elide the code.

If the variable was enabled via the control file, the
__dynamic_pr_debug would be performed with the
use-after-free.
