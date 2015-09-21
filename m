From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC 0/3] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 21 Sep 2015 17:26:24 -0400
Message-ID: <20150921212624.GD3861@oracle.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
 <20150921122422.GA31092@oracle.com>
 <CALx6S34gmbEybQKmsL2=0wGh+LjktBLSimpOCrxWUyTYFFUhfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33065 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756836AbbIUV0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 17:26:30 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S34gmbEybQKmsL2=0wGh+LjktBLSimpOCrxWUyTYFFUhfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/21/15 10:33), Tom Herbert wrote:
> >
> > Some things that were not clear to me from the patch-set:
> >
> > The doc statses that we re-assemble packets the "stated length" -
> > but how will the receiver know the "stated length"?
> 
> BPF program returns the length of the next message. In my testing so
> far I've been using HTTP/2 which defines a frame format with first 3
> bytes being header length field . The BPF program (using LLVM/Clang--
> thanks Alexei!) is just:

Maybe I dont see something about the mux/demux here (I have to 
take a closer look at reserve_psock/unreserve_psock), but 
will every tcp segment have a 3 byte length in the payload?

Not every TCP segment in the RDS-TCP case will have a RDS header,
thus the comments before rds_send_xmit(), thus applying the bpf filter
to a TCP segment holding some "from-the-middle" piece of the RDS dgram
may not be possible 

> > the notes say one can "accept()" over a kcm socket- but "accept()"
> > is itself a connection-oriented concept- one does not accept() on
    :
> The accept method is overloaded on KCM sockets to do the socket
> cloning operation. This is unrelated to TCP semantics, connection
> management is performed on TCP sockets (i.e. before being attached to
> a KCM multiplexor).

If possible,it might be better to use some other
glibc-func/name/syscall/sockopt/whatever
for this, rather than overloading accept().. feels like that would
keep the semantics cleaner, and probably less likely to trip 
up on accept code in the kernel..

--Sowmini
