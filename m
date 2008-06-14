From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Date: Sun, 15 Jun 2008 01:58:28 +0200
Message-ID: <200806150158.28488.tomasz@grobelny.oswiecenia.net>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806111943.42390.tomasz@grobelny.oswiecenia.net> <20080612090710.GA6307@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4780 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbYFOTPY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 15:15:24 -0400
In-Reply-To: <20080612090710.GA6307@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Thursday 12 of June 2008, Gerrit Renker napisa=B3:
> | But if the application wants information about implemented paramete=
rs
> | there is currently no way to get it. It can try to send() packet an=
d
> | check return value (which is quite a hack to be honest). It will wo=
rk if
> | the parameter is not implemented at all. But what happens when you =
try to
> | set priority for a packet and use "simple" qpolicy? AFAIR nothing -=
 you
> | get no information whatsoever that this parameter will not be used =
inside
> | qpolicy.
> |
> | And that's why we need information about parameters in /proc or
> | /proc/sys.
>
> Sorry I can't see here why we need information about parameters. When
> introducing a new socket option there is a convention of how to use i=
t.
>
> For sockopts, the type of the argument is listed for each option type=
=2E
>
You seem to assume that a given qpolicy is a fixed set of functionality=
 at the=20
time of submission to the mainline kernel. In that case you are right, =
the=20
application developer knows which parameters he can attach to a packet =
to be=20
sent (and (s)he knows it at the time of development), so no parameter=20
detection is necessary.

But I view it a bit differently. I think we have to go back to the disc=
ussion=20
about how to add the "timeout" parameter (or any other). Basically ther=
e are=20
two ways:
 1. add a new "timeout" qpolicy (as you proposed),
 2. extend an existing "prio" qpolicy adding DCCP_SCM_TIMEOUT parameter=
 (as I=20
propose). BTW, the "prio" name is a bit misleading, the qpolicy should=20
probably be named "advanced" or something like that.

In other words the basic question is: do we want to add new parameters =
to=20
existing qpolicies (then we need parameter discovery) or we don't want =
new=20
parameters (then we don't need information about parameters available a=
t=20
runtime).

Having defined the alternatives it's time to decide which is better. I,=
 of=20
course, claim that mine (which is adding new parameters to existing=20
qpolicies). That's simply because I think that providing both=20
DCCP_SCM_TIMEOUT and DCCP_SCM_PRIORITY parameters may be useful. And I =
don't=20
see an obvoius way of achieving that goal with "new policy for new para=
meter"=20
approach.

I hope this lengthy text is understandable. Either way, the question is=
=20
simple: what is your concept of adding DCCP_SCM_TIMEOUT parameter?

> | > If we agree on using unique strings to identify qpolicies then we=
 can
> | > keep the runtime discovery much simpler. I think a manpage would =
be
> | > more helpful here, since the runtime discovery of parameters is n=
ot
> | > immediately obvious.
> |
> | Manpage of what? Documentation is certainly needed but before writi=
ng one
> | we need to have a basic implementation we agree upon.
> | --
>
> There is indeed a misunderstanding.
>
> We have already an implementation we agreed upon:
> http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=3Ddccp_exp.git;a=
=3Dcommitd
>iff;h=3D87cf8b3ce96397f934775617ba24eb1ff404747a
>
Yes, but I would consider it not yet ready for application development.=
 Why?=20
See subject of this mail and previous paragraphs.

> With a manpage I mean to document
Is there any "man dccp"?

>  * how the two currently available qpolicies ("simple" and "prio") ar=
e
> enabled; * which additional constraints they have (e.g. how they inte=
rpret
> tx_qlen); * information specific to a policy (e.g. that higher priori=
ty
> values in the "prio" policy mean a higher priority, comparable to
> SO_PRIORITY in socket(7)); * which ancillary data the policies requir=
e (the
> procfs parameters) - simple: no ancillary parameters
>    - prio:   u32 priority value, passed as DCCP_SCM_PRIORITY via cmsg=
(3),
>              using a level of SOL_DCCP and a length of
> CMSG_LEN(sizeof(uint32_t)); * ... probably I have missed something he=
re
>
=46ine. But where exactly should it be described? Which file? I downloa=
ded=20
latest man pages from [1] but dccp is not even mentioned there. Or shou=
ld a=20
new man page be created (which would involve explaining what is dccp in=
 the=20
first place)?

[1] http://www.kernel.org/pub/linux/docs/manpages/man-pages-2.80.tar.bz=
2

> With that kind of documentation, I think, we would not need runtime
> discovery of parameters.
I still don't agree, see previous paragraphs.
--=20
Regards,
Tomasz Grobelny
