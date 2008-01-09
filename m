From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Re: SACK scoreboard
Date: Tue, 8 Jan 2008 17:34:03 -0800
Message-ID: <aa7d2c6d0801081734t363768ffi31adb3bd26e639c7@mail.gmail.com>
References: <Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>
	 <20080107.233617.203640686.davem@davemloft.net>
	 <4783AA29.3080406@psc.edu>
	 <20080108.144456.173014334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, quetchen@caltech.edu
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:46619 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbYAIBeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 20:34:04 -0500
Received: by py-out-1112.google.com with SMTP id u52so79909pyb.10
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2008 17:34:04 -0800 (PST)
In-Reply-To: <20080108.144456.173014334.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings David,

On 08/01/2008, David Miller <davem@davemloft.net> wrote:
> From: John Heffner <jheffner@psc.edu>
>
> > I haven't thought about this too hard, but can we approximate this by
> > moving scaked data into a sacked queue, then if something bad happens
> > merge this back into the retransmit queue?
>
> That defeats the impetus for the change.
>
> We want to free up the data, say, 2 packets at a time as
> ACKs come in.  The key goal is smooth liberation of
> retransmit queue packets over time.

John also suggested freeing the packets as a lower priority task, just
doing it after they're acknowledged.

When the ACK finally comes, you could do something like moving John's
entire list of packets to a "to be freed" list, and free a few every
time (say) another ACK comes in.

$0.02,
Lachlan

-- 
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/~lachlan
