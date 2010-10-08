From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] sysctl: fix min/max handling in
	__do_proc_doulongvec_minmax()
Date: Sat, 9 Oct 2010 00:13:44 +0800
Message-ID: <20101008161344.GG4088@hack>
References: <20101004085913.GR14068@sgi.com> <1286183058.18293.26.camel@edumazet-laptop> <20101004093439.GG5189@cr0.nay.redhat.com> <1286187030.18293.33.camel@edumazet-laptop> <20101004103545.GJ5189@cr0.nay.redhat.com> <1286188701.18293.57.camel@edumazet-laptop> <20101005130117.GK5170@cr0.nay.redhat.com> <20101007071859.GD5471@cr0.nay.redhat.com> <20101007092538.GE5471@cr0.nay.redhat.com> <1286445081.2912.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Robin Holt <holt@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, ebiederm@xmission.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1286445081.2912.15.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 07, 2010 at 11:51:21AM +0200, Eric Dumazet wrote:
>Le jeudi 07 octobre 2010 =C3=A0 17:25 +0800, Am=C3=A9rico Wang a =C3=A9=
crit :
>> >>
>> >
>> >Here is the final one.
>>=20
>> Oops, that one is not correct. Hopefully this one
>> is correct.
>>=20
>> --------------->
>>=20
>> Eric D. noticed that we may trigger an OOPS if we leave ->extra{1,2}
>> to NULL when we use proc_doulongvec_minmax().
>>=20
>> Actually, we don't need to store min/max values in a vector,
>> because all the elements in the vector should share the same min/max
>> value, like what proc_dointvec_minmax() does.
>>=20
>
>If we assert same min/max limits are to be applied to all elements,
>a much simpler fix than yours would be :
>
>diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>index f88552c..8e45451 100644
>--- a/kernel/sysctl.c
>+++ b/kernel/sysctl.c
>@@ -2485,7 +2485,7 @@ static int __do_proc_doulongvec_minmax(void *dat=
a, struct ctl_table *table, int
> 		kbuf[left] =3D 0;
> 	}
>=20
>-	for (; left && vleft--; i++, min++, max++, first=3D0) {
>+	for (; left && vleft--; i++, first=3D0) {
> 		unsigned long val;
>=20
> 		if (write) {
>
>
>Please dont send huge patches like this to 'fix' a bug,
>especially on slow path.

Well, my patch makes that horrible code a little better. :)

>
>First we fix the bug, _then_ we can try to make code more=20
>efficient or more pretty or shorter.
>
>So the _real_ question is :
>
>Should the min/max limits should be a single pair,
>shared by all elements, or a vector of limits.
>

Yes, actually I talked with Eric W. about this before
sending the patch.

I also checked the users of proc_doulongvec_minmax(),
none of them are using more than one limit, so it is
safe to remove that.


--=20
Live like a child, think like the god.
=20
