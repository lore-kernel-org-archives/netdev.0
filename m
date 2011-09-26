From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Disable false positive memory leak report
Date: Mon, 26 Sep 2011 11:46:46 +0200
Message-ID: <1317030406.2557.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+v9cxao_66a1Jb2L4M3fmUvNv8+QzWTFMqu7Dxnh7a5Zyqt0g@mail.gmail.com>
	 <1317014958.2853.0.camel@edumazet-laptop>
	 <CA+v9cxZk_bsxrnn8zS-viH-0Wozz-T0XiFB0AE1fOOKqjcQ2ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Huajun Li <huajun.li.lee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63354 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952Ab1IZJqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 05:46:36 -0400
Received: by bkbzt4 with SMTP id zt4so5601757bkb.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 02:46:35 -0700 (PDT)
In-Reply-To: <CA+v9cxZk_bsxrnn8zS-viH-0Wozz-T0XiFB0AE1fOOKqjcQ2ZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 septembre 2011 =C3=A0 16:42 +0800, Huajun Li a =C3=A9crit :
> Eric, thanks for your response. :)
>=20
> 2011/9/26 Eric Dumazet <eric.dumazet@gmail.com>:

> > This makes no sense to me.
> >
> > per-cpu variables are taken into account by kmemleak.
> >
>=20
> Yes, I think so.
>=20
> > If not, you should report this problem to kmemleak maintainer.
> >
>=20
> To deal with false positives/negatives, in kmemleak document, it says=
:
> ...
> The false positives are objects wrongly reported as being memory leak=
s
> (orphan). For objects known not to be leaks, kmemleak provides the
> kmemleak_not_leak function. The kmemleak_ignore could also be used if
> the memory block is known not to contain other pointers and it will n=
o
> longer be scanned.
> ...
>=20

But this interface should be only used in very specific situations, not
for transient kmemleak reports.

(When the pointer to allocated block is not stored in memory, or only
stored in the object itself : A detached area of memory)

AFAIK, its almost never used :

# git grep kmemleak_not_leak
Documentation/kmemleak.txt:kmemleak_not_leak     - mark an object as no=
t a leak
Documentation/kmemleak.txt:kmemleak_not_leak function. The kmemleak_ign=
ore could also be used if
arch/sparc/kernel/irq_64.c:     kmemleak_not_leak(bucket);
fs/block_dev.c: kmemleak_not_leak(bd_mnt);
fs/nfs/dir.c:   kmemleak_not_leak(string->name);
include/linux/kmemleak.h:extern void kmemleak_not_leak(const void *ptr)=
 __ref;
include/linux/kmemleak.h:static inline void kmemleak_not_leak(const voi=
d *ptr)
kernel/module.c:        kmemleak_not_leak(ptr);
mm/kmemleak.c: * kmemleak_not_leak - mark an allocated object as false =
positive
mm/kmemleak.c:void __ref kmemleak_not_leak(const void *ptr)
mm/kmemleak.c:EXPORT_SYMBOL(kmemleak_not_leak);
mm/kmemleak.c:                  kmemleak_not_leak(log->ptr);
mm/page_cgroup.c:       kmemleak_not_leak(base);


percpu variables are not specific these days, and kmemleak definitely
knows about them.

> For some scenarios, _maybe_ it's hard for kmemleak to give report
> exactly, and I think it is known issue for the maintainers, so hope
> there will be a powerful version soon. :)
> However, before the new version of kmemleak(if there is new version)
> comes, is it possible to disable this false positive report as other
> components? You know, other guys maybe also check the code once they
> meet the report again just like me.

We are not going to add patches to work around a core (kmemleak) issue,
especially without kmemleak maintainer feedback.
