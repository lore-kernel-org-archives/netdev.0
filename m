From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: a question about the kcm proposal
Date: Mon, 12 Oct 2015 18:20:45 -0400
Message-ID: <20151012222045.GB20800@oracle.com>
References: <20151012195132.GY14646@oracle.com>
 <CALx6S34fN1W+jCKUFHWrLBmtgYBzMmP6sDx-zfeSX2bpnmvs-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	davejwatson@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17429 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458AbbJLWUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 18:20:55 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S34fN1W+jCKUFHWrLBmtgYBzMmP6sDx-zfeSX2bpnmvs-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/12/15 15:05), Tom Herbert wrote:
> > There is a different but related problem in this space- existing TLS/DTLS
> > libraries (openssl, gnutls etc) only know how to work with tcp
> > or udp sockets - they do not know anything about PF_RDS or the
> > newly proposed kcm socket type.
> >
> TLS-in-kernel would be a lower layer so it shouldn't have to know
> anything about RDS or KCM. If it makes sent KCM could be used for
> parsing TLS records themselves...

I wouldn't quite jump to that conclusion just yet though :-)

there are a lot of alternatives- you could have a uspace module
that shims between the application and kcm (even something that gets
LD_PRELOADed) and adds the right kcm header as needed. Or you
could use ipsec/ike..

tls in the kernel can be quite complex and history shows that it
can easily become hard to maintain: uspace TLS (both the protocol itself,
and the negotiated crypto) tend to move much faster than kernel changes
(at least that's what the 10+ year long solaris-kssl experiment found).

There is another aspect to this: in the DB world, for example,
I might seriously care about encrypting my payroll-database, but not
care so much about the christmas-potluck-database. Thus allowing the
uspace to select when (and what type of crypto algo) to use is a flexibiility
offered by TLS that a "kernel-TLS" would have a hard time matching.

> The design of TLS in the kernel is that it will be enabled on the TCP
> socket, so that receive and transmit path are below RDS and KCM. We
> have the transmit path for TLS-in-kernel running with good preliminary
> results, we will post that at least as RFC shortly. Receive side still
> seems to be feasible.

yes, please share.

TLS does complex things like mid-session CCS. Such things can result
in a lot of asyncrony in the kernel. Given that ipsec has already crossed 
that bridge, I, for one, would like to understand the trade-offs.

The question in my mind,  is "how does this match up with 
transport mode ipsec/ike", and if it does not, why not? The only 
difference (in theory) is whether you do encryption before, or after,
adding the transport (tcp/udp) header, so if there is a big perf gap,
we need to understand why.

--Sowmini
