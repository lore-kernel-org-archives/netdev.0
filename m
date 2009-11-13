From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Thu, 12 Nov 2009 22:26:08 -0800
Message-ID: <20091112222608.79d90e9e@nehalam>
References: <200911130701.14847.opurdila@ixiacom.com>
	<200911130720.19671.opurdila@ixiacom.com>
	<4AFCF8D3.6090905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40034 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752838AbZKMG0T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 01:26:19 -0500
In-Reply-To: <4AFCF8D3.6090905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 07:12:35 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Octavian Purdila a =C3=A9crit :
> > On Friday 13 November 2009 07:01:14 you wrote:
> >> This patch speeds up the network device name allocation for the ca=
se
> >> where a significant number of devices of the same type are created
> >> consecutively.
> >>
> >> Tests performed on a PPC750 @ 800Mhz machine with per device sysct=
l
> >> and sysfs entries disabled:
> >>
> >> Without the patch           With the patch
> >>
> >> real    0m 43.43s	    real    0m 0.49s
> >> user    0m 0.00s	    user    0m 0.00s
> >> sys     0m 43.43s	    sys     0m 0.48s
> >>
> >=20

No one has give a reasonable use case for this network device name
explosion, what is the benchmark doing this nosense, and how do I
get paid to do it...

But I have to say no for another reason. You cause the kernel to choose
a different name for the case where a device is deleted or renamed.
The old code would find and fill the hole when a new device was added.

Since this is a semantic ABI change, the kind that drives users nuts.

--=20
