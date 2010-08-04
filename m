From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 4 Aug 2010 12:06:47 -0700
Message-ID: <AANLkTimxv1y3QJ7s+ghi1FFCcwnUVWT1n6dvT-NNN=Oo@mail.gmail.com>
References: <20100803.203814.59697285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100803.203814.59697285.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 3, 2010 at 8:38 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> Another release, another merge window, another set of networking
> changes to merge :-)

Ok, merged. But you should double-check my merge resolution fixes,

I'm also a bit unhappy about how it introduces new warnings in very
subtle ways. I started wondering why the hell I suddenly had SCSI
warnings even though I hadn't pulled the SCSI tree yet. It was due to
the dev_printk() changes in commit 99bcf217183e0 (""), which ends up
causing things like

  drivers/scsi/constants.c: In function =91scsi_print_sense=92:
  drivers/scsi/constants.c:1407: warning: zero-length gnu_printf format=
 string
  drivers/scsi/constants.c:1413: warning: zero-length gnu_printf format=
 string
  drivers/scsi/constants.c: In function =91scsi_print_result=92:
  drivers/scsi/constants.c:1456: warning: zero-length gnu_printf format=
 string
  ...

which is a bit annoying. But more annoying was that you must have
known about this, and I'd have been much happier not seeing it as a
new surprise.

            Linus
