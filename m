From: Jinxin Zheng <jinxinzheng@gmail.com>
Subject: Re: ipv4 udplite broken in >=linux-3.0 ?
Date: Sat, 19 Nov 2011 15:08:35 +0800
Message-ID: <CABPbr_kB3mRZWoVcRVN3rmqtNmQqXq-G6P9fwE=3GDN9B_OGVw@mail.gmail.com>
References: <CABPbr_msepemFt4ezGVRk3QS0MU3F47MKimfV4Y+6jqvUrLFeA@mail.gmail.com>
	<20111118120430.GG3317@hell>
	<CABPbr_=fgB-AKK3H8ryccqA7SUO=ejZiWP7tEKYLh=qNG5r7CQ@mail.gmail.com>
	<20111118232729.GA3902@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111118232729.GA3902@gerrit.erg.abdn.ac.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 19, 2011 at 7:27 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> =
wrote:
> Jinxin, -
> | On Fri, Nov 18, 2011 at 8:04 PM, Hagen Paul Pfeifer <hagen@jauu.net=
> wrote:
> | > * Jinxin Zheng | 2011-11-18 12:09:25 [+0800]:
> | >
> | >>I don't know how to debug udplite. Can any one of you give me a t=
ip on
> | >>how to get more debug info, then I can do further test and provid=
e
> | >>with it?
> | >
> | > net-next works for me:
> That is very likely the point. Between 2.6.39 and 3.0 UDP-Lite checks=
um coverage was
> broken and got only recently fixed. The correct kernel version should=
 have the
> commit shown below. Alternatively, you can check include/net/udplite.=
h, which
> should mention "Slow-path" and "Fast-Path" computation. UDP-Litev6 st=
ill uses the
> slow path, that is why it is not affected.
>
>
> commit f36c23bb9f822904dacf83a329518d0a5fde7968
> Author: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Date: =A0 Mon Oct 17 19:07:30 2011 -0400
>
> =A0 =A0udplite: fast-path computation of checksum coverage
>
> =A0 =A0Commit 903ab86d195cca295379699299c5fc10beba31c7 of 1 March thi=
s year ("udp: Add
> =A0 =A0lockless transmit path") introduced a new fast TX path that br=
oke the checksum
> =A0 =A0coverage computation of UDP-lite, which so far depended on up-=
>len (only set
> =A0 =A0if the socket is locked and 0 in the fast path).
>
> =A0 =A0Fixed by providing both fast- and slow-path computation of che=
cksum coverage.
> =A0 =A0The latter can be removed when UDP(-lite)v6 also uses a lockle=
ss transmit path.
>
>

Thanks, Gerrit. Upgrading to the upstream linux-3.2-rc2 fixed the probl=
em :)

--=20
Zheng Jinxin
