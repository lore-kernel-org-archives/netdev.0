From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via /proc
Date: Sun, 7 Nov 2010 15:22:34 -0800
Message-ID: <AANLkTikDeVXcYRXqcq-qD_mf19awnKPTYGZbZguxJLDm@mail.gmail.com>
References: <87sjzcssx5.fsf@basil.nowhere.org> <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, "Ted Ts'o" <tytso@mit.edu>,
	Dan Rosenberg <drosenberg@vsecurity.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59158 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751336Ab0KGXYk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Nov 2010 18:24:40 -0500
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oA7NMsmD016441
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Sun, 7 Nov 2010 15:22:55 -0800
Received: by iwn41 with SMTP id 41so3354268iwn.19
        for <netdev@vger.kernel.org>; Sun, 07 Nov 2010 15:22:54 -0800 (PST)
In-Reply-To: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 7, 2010 at 2:48 PM, Chas Williams (CONTRACTOR)
<chas@cmf.nrl.navy.mil> wrote:
>
> i suppose one could use idr to map the pointers to unique values. =A0=
the
> infiniband code uses this technique>

We already _have_ the unique value that /proc uses - the inode number.
It's what lsof and friends use to match things across different files
anyway.

Why are people arguing about stupid things? If it's wrong to expose
kernel pointers in /proc (and I do think it generally is something we
should try to avoid), then we already do have the natural alternative.
Which happens to be what the patch already does.

So the only question is whether kernel pointers are an information
leak worth worrying about. Personally, I think it's just damn stupid
to expose a kernel pointer unless you _have_ to. There is absolutely
no reason to expose the address of a socket in /proc, perhaps unless
you're in some super-duper-debugging mode that no sane person would
ever use outside of specialized network debugging (and I bet that in
that case you still shouldn't expose it in a _normal_ proc file, but
in debugfs or something).

                          Linus
