From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Re: [RFC PATCH net-2.6.25 uncompilable] [TCP]: Avoid breaking GSOed skbs when SACKed one-by-one
Date: Wed, 12 Dec 2007 15:35:49 -0800
Message-ID: <aa7d2c6d0712121535y31bea3a6v14e270293c272e6f@mail.gmail.com>
References: <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
	 <20071211.043239.224938181.davem@davemloft.net>
	 <aa7d2c6d0712111614k2832f51axa8bc9736ac7ec796@mail.gmail.com>
	 <20071212.071136.26499607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	quetchen@caltech.edu, "Darryl Veitch" <d.veitch@ee.unimelb.edu.au>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:43673 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbXLLXfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 18:35:51 -0500
Received: by py-out-1112.google.com with SMTP id u77so1075275pyb.16
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 15:35:51 -0800 (PST)
In-Reply-To: <20071212.071136.26499607.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings Dave,

On 12/12/2007, David Miller <davem@davemloft.net> wrote:
> From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
> Date: Tue, 11 Dec 2007 16:14:36 -0800
>
> > This thread started because TCP processing interferes with RTT
> > estimation.  This problem would be eliminated if time-stamping were
> > done as soon as the packet comes off the NIC.
>
> We don't do that because such timestamping is too expensive.
> It used to be the case that we did this, but we stopped doing
> that a long time ago.
>
> On x86 for example, timestamping can involve touching a slow
> I/O device to read the timestamp.  We do not want to do that
> for every packet.

OK.  Thanks for the background.

I thought that a TSC read was fairly cheap.  Any messing around to
interpret it could be the responsibility of any task which actually
needs a high-resolution timestamp, couldn't it?  If TSC is disabled,
then the timestamp field could be set to "invalid".

> Also, we timestamp differently for TCP, the global high
> resolution timestamp is overkill for this purpose.

Overkill for Reno and Cubic, but useful for Vegas, LP, veno, Illinois
and YeAH which are all in the kernel.  They currently use "high
resolution" timestamps which are effectively quantized to the
scheduler resolution because of the way timestamping is done --
reading a high-resolution time source when a task is scheduled.

> Really, this is a silly idea

Oh... :(

> and would only be a bandaid
> for the problem at hand, that TCP input processing is
> too expensive in certain circumstances.

That problem should certainly be fixed as well -- I wasn't suggesting
this as an alternative.  Will fixing it fix the problem of those TCP
modules suffering from CPU load from other sources?

(I'm Cc'ing this to Darryl Veitch who has often wanted driver-level
time-stamping for achieving high-resolution synchronization between
hosts.)

Cheers,
Lachlan

-- 
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/~lachlan
