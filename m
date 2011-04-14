From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: ipv4: add IPPROTO_ICMP socket kind
Date: Thu, 14 Apr 2011 12:16:15 +0300
Message-ID: <BANLkTinh0cmb0hzpVdm5XemT5NeULeAoHQ@mail.gmail.com>
References: <BANLkTi=ogJg_uJqsJFpnwnnr6LS+SFT3Vg@mail.gmail.com>
	<20110413113204.GB6948@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>,
	Solar Designer <solar@openwall.com>,
	Kees Cook <kees.cook@canonical.com>,
	Dan Rosenberg <dan.j.rosenberg@gmail.com>,
	Eugene Teo <eugene@redhat.com>,
	Nelson Elhage <nelhage@ksplice.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Pekka Savola <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110413113204.GB6948@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 13, 2011 at 2:32 PM, Vasiliy Kulikov <segoon@openwall.com> =
wrote:
> On Wed, Apr 13, 2011 at 13:29 +0300, Alexey Dobriyan wrote:
>> On Sat, Apr 9, 2011 at 1:15 PM, Vasiliy Kulikov <segoon@openwall.com=
> wrote:
>> > This patch adds IPPROTO_ICMP socket kind.
>>
>> > + =A0 =A0 =A0 seq_printf(f, "%5d: %08X:%04X %08X:%04X"
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " %02X %08X:%08X %02X:%08lX %08X %5d=
 %8d %lu %d %p %d%n",
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bucket, src, srcp, dest, destp, sp->=
sk_state,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_wmem_alloc_get(sp),
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_rmem_alloc_get(sp),
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, 0L, 0, sock_i_uid(sp), 0, sock_i_=
ino(sp),
>>
>> These zeroes can be embedded into format string for slightly faster =
printing.
>
> Is it really needed? =A0I mean, it is not a fast path, so such a smal=
l
> overhead is not very bad. =A0But embedding them into the string makes=
 it a
> bit more difficult to read.

In fact, if field is always zero, it can be removed altogether.
Also, there was big discussion re exposing kernel socket pointers,
which this file continue to do.

> +               atomic_read(&sp->sk_refcnt), sp,
> +               atomic_read(&sp->sk_drops), len);
