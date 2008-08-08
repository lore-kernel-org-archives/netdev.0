From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Fri, 8 Aug 2008 21:19:37 +0200
Message-ID: <200808082119.37778.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080808185356.GC607@linux-os.sc.intel.com> <489C97FB.2030408@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, viro@zeniv.linux.org.uk,
	vegard.nossum@gmail.com
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:39682 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750695AbYHHTTj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 15:19:39 -0400
In-Reply-To: <489C97FB.2030408@zytor.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 8. August 2008 21:01 schrieb H. Peter Anvin:
> Suresh Siddha wrote:
> > I propose to go with wolf's patch which add's kernel_fpu_begin() an=
d
> > kernel_fpu_end() around these instructions. This is the correct fix
> > (unless there is something wrong in my above understanding).
>
> It's technically overkill, if (and only if!) these instructions don't
> actually touch the SSE state (most likely they're using the SSE
> pipeline, and need this stuff to deal with power management issues.)
>
> However, overkill is a good way to make sure something is dead.
> Applying the patch will make sure we fix the regression, and we can
> worry about optimizing this further post-2.6.27.
>
> 	-hpa

Probably

drivers/crypto/padlock-sha.c
drivers/char/hw_random/via-rng.c

needs a fix, too.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leiter EDV
Leopoldstra=DFe 15
80802 M=FCnchen
Tel: +49 89 38196 276
=46ax: +49 89 38196 150
Email: wolfgang.walter@stwm.de
http://www.studentenwerk-muenchen.de/
