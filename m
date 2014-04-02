From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v4 net] xen-netback: disable rogue vif in kthread context
Date: Wed, 2 Apr 2014 11:21:14 +0100
Message-ID: <20140402102114.GF6382@zion.uk.xensource.com>
References: <1396352772-7884-1-git-send-email-wei.liu2@citrix.com>
 <20140401.162717.1962834632849633175.davem@davemloft.net>
 <1396429540.8667.263.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <wei.liu2@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>,
	<edwin@etorok.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:1276 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755344AbaDBKVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2014 06:21:15 -0400
Content-Disposition: inline
In-Reply-To: <1396429540.8667.263.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2014 at 10:05:40AM +0100, Ian Campbell wrote:
> On Tue, 2014-04-01 at 16:27 -0400, David Miller wrote:
> > From: Wei Liu <wei.liu2@citrix.com>
> > Date: Tue, 1 Apr 2014 12:46:12 +0100
> >=20
> > > When netback discovers frontend is sending malformed packet it wi=
ll
> > > disables the interface which serves that frontend.
> > >=20
> > > However disabling a network interface involving taking a mutex wh=
ich
> > > cannot be done in softirq context, so we need to defer this proce=
ss to
> > > kthread context.
> > >=20
> > > This patch does the following:
> > > 1. introduce a flag to indicate the interface is disabled.
> > > 2. check that flag in TX path, don't do any work if it's true.
> > > 3. check that flag in RX path, turn off that interface if it's tr=
ue.
> > >=20
> > > The reason to disable it in RX path is because RX uses kthread. A=
fter
> > > this change the behavior of netback is still consistent -- it won=
't do
> > > any TX work for a rogue frontend, and the interface will be event=
ually
> > > turned off.
> > >=20
> > > Also change a "continue" to "break" after xenvif_fatal_tx_err, as=
 it
> > > doesn't make sense to continue processing packets if frontend is =
rogue.
> > >=20
> > > This is a fix for XSA-90.
> > >=20
> > > Reported-by: T=F6r=F6k Edwin <edwin@etorok.net>
> > > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> >=20
> > Applied.
>=20
> Thanks.
>=20
> Wei -- can you advise as to which stable trees this should be queued
> for? Looks like 3.12 onwards according to
> http://xenbits.xen.org/xsa/advisory-90.html which says the issue aros=
e
> between 3.11 and 3.12-rc1?
>=20

Correct.

Wei.

> Cheers,
> Ian.
>=20
