From: Eddie Kohler <kohler@cs.ucla.edu>
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Date: Mon, 17 Nov 2008 11:27:29 -0800
Message-ID: <4921C5A1.5030609@cs.ucla.edu>
References: <5bc4c4570810171021ua6371ebs1ffdf471382a8b13@mail.gmail.com> <20081105052733.GG6564@gerrit.erg.abdn.ac.uk> <5bc4c4570811060538h2d662507u5de1fb62c61cd569@mail.gmail.com> <20081106152048.GA3621@gerrit.erg.abdn.ac.uk> <20081106153824.GA9709@ghostprotocols.net> <5bc4c4570811060946j4d5d8d1mf88f8b92c72b59c7@mail.gmail.com> <5bc4c4570811061004nfc2afdcn6035d49ae654aef1@mail.gmail.com> <5bc4c4570811061017j3acef860vee84992e7295d06d@mail.gmail.com> <5bc4c4570811061405qe72e43cx861c537885804132@mail.gmail.com> <20081108085035.GA7112@gerrit.erg.abdn.ac.uk> <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Leandro Sales <leandroal@gmail.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	ian.mcdonald@jandi.co.nz, DCCP Mailing List <dccp@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from out-66.smtp.ucla.edu ([169.232.46.167]:41182 "EHLO
	out-66.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbYKQTfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 14:35:48 -0500
In-Reply-To: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerrit Renker wrote:
> I would appreciate some advice and insights regarding the use of
> high-resolution timers within a transport protocol, specifically
> DCCP with CCID-3 (RFC 5348).
> 
 > ...
 >
> Summing up, I have doubts that basing CCID-3 will bring advantages and
> would much rather go the other way and (consistently) use lower resolution.
> 
> Thoughts?

I agree.  If one way must be chosen, then choose lower resolution timers.

The biggest potential problem with lower-resolution timers is that a sender's 
rate might be limited, not by network characteristics, but by timer 
resolution.  But DCCP allows a fair amount of burstiness already.  And there 
may be ways to avoid rate limitation in common cases without resorting to 
hrtimers.  For example, a sending application could use a mixture of 
non-blocking system calls, allowing the sending application to "poke" the DCCP 
implementation on every scheduling.

At any rate, it seems worth trying.

Eddie

