From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: Kernel 4.1.12 crash
Date: Mon, 30 Nov 2015 16:03:37 +0100
Message-ID: <20151130150337.GC3059@alphalink.fr>
References: <564F26FF.3040605@seti.kr.ua>
 <564FA904.7020603@gmail.com>
 <5650287B.9070901@seti.kr.ua>
 <56514FF5.7060906@gmail.com>
 <5654EBE8.9030705@seti.kr.ua>
 <20151125141048.GA3868@alphalink.fr>
 <5655CCAE.6000300@seti.kr.ua>
 <20151126164452.GA2988@alphalink.fr>
 <565B7699.8030105@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
To: Andrew <nitr0@seti.kr.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:50847 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269AbbK3PDk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 10:03:40 -0500
Content-Disposition: inline
In-Reply-To: <565B7699.8030105@seti.kr.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 12:05:13AM +0200, Andrew wrote:
> 26.11.2015 18:44, Guillaume Nault =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> >On Wed, Nov 25, 2015 at 04:58:54PM +0200, Andrew wrote:
> >>25.11.2015 16:10, Guillaume Nault =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> >>>On Wed, Nov 25, 2015 at 12:59:52AM +0200, Andrew wrote:
> >>>>Hi.
> >>>>
> >>>>I tried to reproduce errors in virtual environment (some VMs on m=
y
> >>>>notebook).
> >>>>
> >>>>I've tried to create 1000 client PPPoE sessions from this box via=
 script:
> >>>>for i in `seq 1 1000`; do pppd plugin rp-pppoe.so user test passw=
ord test
> >>>>nodefaultroute maxfail 0 persist nodefaultroute holdoff 1 noauth =
eth0; done
> >>>>
> >>>I've tried to reproduce the bug with your script, but couldn't get
> >>>anything to crash (VM is Debian Jessie i386 running on KVM with up=
stream
> >>>kernel 4.1.12). Does the crash happen before all sessions get
> >>>established?
> >>Yes, crash happens even before all daemon instances are started. Se=
ssions
> >>don't get established because BRAS configured to reject sessions (s=
o a lot
> >>of concurrent connection retries happens) - I still didn't created =
account
> >>for test user on it.
> >>
> >Ok, I got the crash too. In fact I had misunderstood your previous
> >message, crash happens when PPP sessions don't get established
> >(authentication failures in my case).
> >
> >I'll investigate on that and let you know.
>=20
> It seems like bug appears on mass ppp devices removing (I planned to =
use
> this test environment to reproduce BRAS periodical crashes, but sudde=
nly
> I've got crashes on test client).
>=20
> I've checked it with some kernels - it's present in 4.3.0, but it isn=
't
> present in 3.10.57. I'll try to build 3.14/3.18 kernels to look how t=
hey
> will work in this case.

Yes, it most likely was introduced by 287f3a943fef ("pppoe: Use
workqueue to die properly when a PADT is received"). I still have to
figure out why.
