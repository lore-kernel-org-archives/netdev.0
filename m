From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [QPOLICY]: Ignore packets with specific priority
Date: Mon, 3 Nov 2008 00:27:42 +0100
Message-ID: <200811030027.43084.tomasz@grobelny.oswiecenia.net>
References: <200810262233.54649.tomasz@grobelny.oswiecenia.net> <4909FAEF.8040900@grobelny.oswiecenia.net> <56979.148.187.160.35.1225468273.squirrel@148.187.160.35>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Arnaldo Carvalho de Melo" <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4119 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752AbYKBX2H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 18:28:07 -0500
In-Reply-To: <56979.148.187.160.35.1225468273.squirrel@148.187.160.35>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Friday 31 of October 2008, napisa=C5=82e=C5=9B:
> >> One difficulty that I see is what to do when the send socket is
> >> non-blocking.
> >
> > But socket doesn't get into non-blocking mode until specifically
> > requested by fcntl(soc, F_SETFL, O_NONBLOCK) call, does it?
>
> Yes - the problem is that the code does not stop the user from
> setting non-blocking mode on the socket.
>
Yes, currently this concept is more a usage convention than a new inter=
face in=20
a strict sense. And so it is quite easy to misuse it.

> >> Maybe purists will not like this since the complexity is now shift=
ed to
> >> the
> >> user-kernel interface. But it may well be a start to develop some =
kind
> >> of
> >> new interface which achieves the same in a cleaner way.
> >
> > I think that much of the previously written qpolicy code could be
> > removed from the kernel so the interface would be really simple. No
> > policy switching, no fancy parameters, etc. The only difference fro=
m
> > standard interface would be that a packet could have a 'drop me' fl=
ag
> > (priority 65 in my code). Ok, I agree some may consider it tricky b=
ut I
> > wouldn't call it complicated. The complicated part is meant to be o=
n the
> > userspace side. And that in my opinion has many advantages: easier
> > debugging, easier to add new (possibly complex) queuing policies.
>
> I fully agree with the idea, it is the realisation that causes me
> some headaches. It would be great if the code need not call send() tw=
ice
> to send a single packet, and if an skb need not be allocated in order=
 to
> create a "waiting effect" in userspace.
>
> The other alternative that I see is to come up with completely new
> system calls - as done in SCTP for instance. But this would only make=
 snse
> if with the present means things get too ugly; i.e. if the
> new semantics can not be expressed with the given system calls.
>
> So there is agreement on the idea, I hope is that realisation
> can be refined - without overloading existing calls too much.
>
What about using select() call to get the effect of waiting? I think th=
at=20
select() is precisely designed for such a thing. It is generally used o=
n=20
reading from sockets so it could be used on writing to sockets as well.=
 I=20
haven't looked at the code yet to know how complicated it might be to=20
implement but it seems to be a nice idea to consider.

> >> Can you please narrow down what is happening with CCID-3.  CCID-3 =
is
> >> very
> >> complicated and sensitive, so it is possible that the problem is w=
ithin
> >> CCID-3 and not the qpolicy code - need more detailed information.
> >
> > On one test it seemed not to work at all in my setup: ccid3 seems n=
ot to
> > limit traffic at all. But that was just one test so it may well be =
my
> > fault.
>
> If you notice anything odd, please do report it on the mailing list.
>
I will as soon as I have some useful information (that is when I test i=
t on=20
fresh git tree).
--=20
Regards,
Tomasz Grobelny
