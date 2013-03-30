From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v2] include/linux: printk is needed in filter.h when CONFIG_BPF_JIT
 is defined
Date: Sat, 30 Mar 2013 11:10:55 +0800
Message-ID: <515657BF.7010101@asianux.com>
References: <5153DC24.4010104@asianux.com> <5154ED65.5090607@asianux.com> <20130329.153447.426374969178935845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, dborkman@redhat.com, wad@chromium.org,
	eparis@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:36785 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757801Ab3C3DL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 23:11:26 -0400
In-Reply-To: <20130329.153447.426374969178935845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B403=E6=9C=8830=E6=97=A5 03:34, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Fri, 29 Mar 2013 09:24:53 +0800
>=20
>> >=20
>> >   for make V=3D1 EXTRA_CFLAGS=3D-W ARCH=3Darm allmodconfig
>> >     printk is need when CONFIG_BPF_JIT is defined
>> >     or it will report pr_err and print_hex_dump are implicit decla=
ration
>> >=20
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
> There are no references to pr_err nor print_hex_dump in this
> filter.h header file.

  maybe we see the different tree.
  I find it in next-20130328.

  please help check, thanks.


commit 79617801ea0c0e6664cb497d4c1892c2ff407364
Author: Daniel Borkmann <dborkman@redhat.com>
Date:   Thu Mar 21 22:22:03 2013 +0100

    filter: bpf_jit_comp: refactor and unify BPF JIT image dump output
   =20
    If bpf_jit_enable > 1, then we dump the emitted JIT compiled image
    after creation. Currently, only SPARC and PowerPC has similar outpu=
t
    as in the reference implementation on x86_64. Make a small helper
    function in order to reduce duplicated code and make the dump outpu=
t
    uniform across architectures x86_64, SPARC, PPC, ARM (e.g. on ARM
    flen, pass and proglen are currently not shown, but would be
    interesting to know as well), also for future BPF JIT implementatio=
ns
    on other archs.
   =20
    Cc: Mircea Gherzan <mgherzan@gmail.com>
    Cc: Matt Evans <matt@ozlabs.org>
    Cc: Eric Dumazet <eric.dumazet@google.com>
    Cc: David S. Miller <davem@davemloft.net>
    Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/filter.h b/include/linux/filter.h
index d2059cb..d7d2508 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -50,6 +50,16 @@ extern int sk_get_filter(struct sock *sk, struct soc=
k_filter __user *filter, uns
 #ifdef CONFIG_BPF_JIT
 extern void bpf_jit_compile(struct sk_filter *fp);
 extern void bpf_jit_free(struct sk_filter *fp);
+
+static inline void bpf_jit_dump(unsigned int flen, unsigned int progle=
n,
+                               u32 pass, void *image)
+{
+       pr_err("flen=3D%u proglen=3D%u pass=3D%u image=3D%p\n",
+              flen, proglen, pass, image);
+       if (image)
+               print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDR=
ESS,
+                              16, 1, image, proglen, false);
+}
 #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->in=
sns)
 #else
 static inline void bpf_jit_compile(struct sk_filter *fp)



--=20
Chen Gang

Asianux Corporation
