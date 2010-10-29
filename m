From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 10:01:19 -0700
Message-ID: <AANLkTi=zieMoDdHgB_aY4xN=A6ErrjUWpaME1WwWrvnL@mail.gmail.com>
References: <20101028.112231.232747062.davem@davemloft.net>
 <AANLkTinAzvfrRHwW-w-Ppdu7LWd7nGTa4EWP=e6pKV2F@mail.gmail.com>
 <1288360820.2092.34.camel@dan> <AANLkTikeaXncdUohUiGF2EkhujYETK5dtyOJASffz2qR@mail.gmail.com>
 <AANLkTi=sUDRzGnkp57OCQUi9APHWLYLShhiTVHLyq1eV@mail.gmail.com> <20101029164532.GV19804@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49588 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934174Ab0J2RBm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 13:01:42 -0400
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9TH1fcq000721
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 10:01:42 -0700
Received: by iwn10 with SMTP id 10so3926851iwn.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 10:01:39 -0700 (PDT)
In-Reply-To: <20101029164532.GV19804@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 29, 2010 at 9:45 AM, Al Viro <viro@zeniv.linux.org.uk> wrot=
e:
>
> I don't see anything obviously broken (and we obviously have allowed
> iov_len =3D=3D 0 cases all along, so if anything, breakage won't be n=
ew).
> However, I wonder if things like sendmsg() for datagrams have warrant=
ies
> against silent truncation. =A0Davem?

You missed that discussion - my argument is that anybody who thinks
that they can send a single packet that is 2GB+ in size are already
screwed. And the packet protocol will have some inherent upper limit
anyway (possibly introduced by just allocation issues, but quite
likely inherent to the protocol itself)

And yes, the iov_len =3D 0 case has always been possible and accepted s=
o
my patch doesn't really change anything. In fact, I think it even
happens (simple example: the easiest way for user space to resume a
partial writev() is to basically subtract out the return value from
the iovec and then re-submit it - so getting zero iovec entries at the
beginning in particular would not necessarily even be odd)

                            Linus
