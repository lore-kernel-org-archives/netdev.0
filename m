From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable
 when performing the upcall
Date: Sat, 25 May 2013 08:02:22 +0100
Message-ID: <20130525070222.GB30252@casper.infradead.org>
References: <cover.1369406826.git.tgraf@suug.ch>
 <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
 <1369421900.3301.431.camel@edumazet-glaptop>
 <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
 <1369432621.3301.445.camel@edumazet-glaptop>
 <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38738 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab3EYHCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 03:02:24 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/13 at 03:18pm, Jesse Gross wrote:
> On Fri, May 24, 2013 at 2:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> My guess is that there isn't a real different for small packets since
> >> everything will be in the cache but it seems worth checking given that
> >> this is optimizing a rare case at the expense of the common one.
> >
> > I really doubt checksumming a SYN/ACK packet is that a performance
> > issue. Do you have performance numbers ?
> >
> > You could always provide a patch to restore this copy/checksum if it
> > really gives a benefit, and if people still use NIC not doing this
> > checksum.
> 
> If it makes a difference then it needs to be addressed before this
> patch goes in since it's the common case. I don't think it will but
> that's why I'm asking for numbers.

I ran TCP_CRR to verify the SYN/ACK use case and I did not
observe a difference. If you have any specific test in mind
I will be glad to run that before posting the 2nd revision.

The CPU numbers as reported was seen when testing with pktgen
at 1400 bytes with 8K flows and a 10/8 random IP source address.
