From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/1] net: Introduce recvmmsg socket syscall
Date: Mon, 12 Oct 2009 22:56:37 -0300
Message-ID: <20091013015637.GB21809@ghostprotocols.net>
References: <1255364440-23271-1-git-send-email-acme@redhat.com> <9b2db90b0910121053h3c422beet487cc9a9b9be2894@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>,
	Paul Moore <paul.moore@hp.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Steven Whitehouse <steve@chygwyn.com>
To: Nir Tzachar <nir.tzachar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:53968 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbZJMCF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 22:05:59 -0400
Received: by qw-out-2122.google.com with SMTP id 9so738960qwb.37
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 19:04:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <9b2db90b0910121053h3c422beet487cc9a9b9be2894@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Oct 12, 2009 at 07:53:43PM +0200, Nir Tzachar escreveu:
> Hi Arnaldo.
> 
> Do you have any plans on how we can further investigate the delays I
> have seen with the second part of the patch? I have tried to simply
> unlock/lock the socket's mutex every couple of iterations inside the

Yeah, that is what tcp does, look at tcp_recvmsg (net/ipv4/tcp.c, line
1505), so I think we should do something along those lines, exactly when
and after which tests is a matter of experimentation.

I'll resume investigation tomorrow.

> loop (to allow the system to process some backlog), but this seems to
> have little to no effect.
 
> Also, a way to enable/disable the no_lock version at runtime will
> greatly help in testing. Maybe by first introducing a second syscall,
> recvmmsg_no_lock, for testing purposes??

I'll come up with a way for that to be possible.

- Arnaldo
