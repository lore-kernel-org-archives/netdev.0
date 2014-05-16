From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bnx2x: Convert return 0 to return rc
Date: Fri, 16 May 2014 13:12:24 -0700
Message-ID: <1400271144.12373.21.camel@joe-AO725>
References: <1400223103.30884.5.camel@joe-AO725>
	 <87B4DDAD5EAFA041BDC28F314593782D0172ECD7@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ariel Elior <ariel.elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87B4DDAD5EAFA041BDC28F314593782D0172ECD7@avmb3.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-05-16 at 12:02 +0000, Dmitry Kravkov wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Joe Perches
> > Sent: Friday, May 16, 2014 9:52 AM
> > To: Ariel Elior; Dmitry Kravkov
> > Cc: netdev; linux-kernel
> > Subject: [PATCH] bnx2x: Convert return 0 to return rc
> >
> > These "return 0;" uses seem wrong as there are
> > rc variables where error return values are set
> > but unused.
[]
> Thanks Joe for catching this!
> 
> Acked-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>

Hello Dmitry.

Couple things actually:
o Could you please update the MAINTAINER entry for
  BNX2X?  Ariel Elior's email address is still listed
  as @broadcom and that seems to bounce.

o I found this via coccinelle actually.
  Julia Lawall submitted a patch to remove unused
  netdev_priv calls.  I modified that to check for
  any expression that returns an unused value and
  found this and many others.  There are a lot of
  false positives though.

@@
local idexpression x;
expression E;
@@
-x = E;
    ... when != x
