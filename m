From: 'Arnaldo Carvalho de Melo' <acme@kernel.org>
Subject: Re: [PATCH/RFC] net: Don't save mid batch datagram processing error
 for next recvmmsg call
Date: Tue, 22 Jul 2014 10:24:10 -0300
Message-ID: <20140722132410.GD20303@kernel.org>
References: <20140721193042.GA20303@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6D1727AECC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Friesen <chris.friesen@windriver.com>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	=?utf-8?B?T25kxZllaiBCw61sa2E=?= <neleai@seznam.cz>,
	Paul Moore <paul@paul-moore.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>,
	Steven Whitehouse <steve@chygwyn.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:44024 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293AbaGVNYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 09:24:19 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1727AECC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Jul 22, 2014 at 08:33:27AM +0000, David Laight escreveu:
> From: Arnaldo Carvalho de Melo 
> > 	I think this addresses the problems reported by David Laight and
> > others, where errors saved on a per socket area could be delivered to a
> > different thread, so I just followed David Laight's suggestion and
> > stopped saving it, we'll return it only if it happens for the first
> > datagram, else we return less entries than asked for.

> > 	Steven, IIRC you was the one that suggested using this
> > mechanism, no? Do you have anything against this move?
 
> +	return datagrams ?: err;
 
> Inline patches, don't attach them.

Oh well, ok, will do next time.
 
> Don't use non-C constructs.

We use it in many places, one could say the kernel isn't written in C
anyway:

[acme@zoo linux]$ find . -name "*.[ch]" | xargs grep '?:' | cut -d'/' -f -2 | sort | uniq -c | sort -nr
    189 ./drivers
     45 ./arch
     33 ./crypto
     30 ./fs
     25 ./net
     23 ./kernel
     22 ./tools
      9 ./sound
      8 ./include
      5 ./security
      5 ./mm
      3 ./block
      2 ./lib
      1 ./scripts
      1 ./ipc
[acme@zoo linux]$

Other than that, are you ok with the change?

- Arnaldo
