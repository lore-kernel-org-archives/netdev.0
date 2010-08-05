From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] isdn: fix information leak
Date: Thu, 5 Aug 2010 12:19:38 +0200
Message-ID: <20100805101938.GH9031@bicker>
References: <20100805093806.GF9031@bicker> <AANLkTin4jtYuaxYfxDAgST857sD2K4Q28mPcPW=xd-V3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:56452 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760091Ab0HEKUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 06:20:19 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTin4jtYuaxYfxDAgST857sD2K4Q28mPcPW=xd-V3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 05, 2010 at 06:08:08PM +0800, Changli Gao wrote:
> On Thu, Aug 5, 2010 at 5:38 PM, Dan Carpenter <error27@gmail.com> wro=
te:
> > The main motivation of this patch changing strcpy() to strlcpy().
> > We strcpy() to copy a 48 byte buffers into a 49 byte buffers. =A0So=
 at
> > best the last byte has leaked information, or maybe there is an
> > overflow? =A0Anyway, this patch closes the information leaks by zer=
oing
> > the memory and the calls to strlcpy() prevent overflows.
>=20
> strlcpy() can handle the terminator NUL. so you don't need to zero it=
=2E

If there are no NUL chars in "rcvmsg->msg_data.byte_array" then strlcpy=
()
is sufficient, but if there is a NUL character then you need to zero th=
e
memory.  The patch handles both possibilities.

regards,
dan carpenter

