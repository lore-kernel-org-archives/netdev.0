From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Date: Wed, 11 Jun 2008 19:43:42 +0200
Message-ID: <200806111943.42390.tomasz@grobelny.oswiecenia.net>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806081421.25688.tomasz@grobelny.oswiecenia.net> <20080610114908.GA25798@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:3897 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880AbYFKRoQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:44:16 -0400
In-Reply-To: <20080610114908.GA25798@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Tuesday 10 of June 2008, Gerrit Renker napisa=B3:
> | > But since it is about dynamic runtime configuration, how about us=
ing
> | > sysfs or configfs instead? This is a brainstorming question, I th=
ink
> | > that sysfs is generally preferred. I don't know how well configfs=
 has
> | > taken off, it is similar, but needs to be added in the configurat=
ion
> | > (under Pseudeo Filesystems, CONFIG_CONFIGFS_FS=3Dy|m)
> | > http://lwn.net/Articles/148973/ and Documentation/filesystems/con=
figs.
> | > But this could be done later as well.
> |
> | procfs has some fine example of being used for this kind of informa=
tion,
> | namely /proc/cpuinfo and /proc/meminfo
> |
> | sysfs: from sysfs-rules.txt: "(...) the sysfs interface cannot prov=
ide a
> | stable interface (...)"
>
> Yes that is a key point and I think we are talking about the same poi=
nt
> here.
>
> I had mentioned sysfs/procfs as alternatives not because they are the=
 best
> possible match, but since it shows that similar problems (and likely
> solutions) exist also in other areas.
>
That's ok, I just mention what I know about them so that we can have co=
mplete=20
argumentation for/against given solution.

> But there are also areas where the rate of change is relatively low o=
r
> even absent: Documentation/ABI/README for instance mentions 4 differe=
nt
> levels of stability (stable/testing/obsolete/removed), the most entri=
es
> are under `testing'.
>
This one should probably be marked as testing too. And probably be move=
d to=20
stable with time (when it proves useful for applications).

> | configfs is for configuring kernel from userspace. Which is quite
> | opposite to what we want.
>
> Ok I think I understand now where you are heading - but then we can g=
o a
> much simpler route: why not implement a sysctl (which is also mirrore=
d in
> /proc/sys) that contains all available/implemented qpolicies as a
> space-separated string, such as
>
> 	cat /proc/sys/net/ipv4/tcp_available_congestion_control ?
>
Could be /proc/sys. I just had an impression that sysctls are for setti=
ng=20
certain variables used in kernel. But as far as I understand it the=20
difference is highly subjective and I'm ok with both /proc and /proc/sy=
s.=20
Would be nice to have more opinions (Arnaldo? others?) whether we shoul=
d=20
favour one over other.

> And I think that it is unnecessarily complex to add the available
> parameters belonging to each qpolicy as well.
>
I think it is critical. If the application just wants to know which qpo=
licies=20
are available it can try to set it with setsockopt(). If it gets an err=
or=20
given qpolicy is unavailable. As simple as that. No need for additional=
=20
interface.
But if the application wants information about implemented parameters t=
here is=20
currently no way to get it. It can try to send() packet and check retur=
n=20
value (which is quite a hack to be honest). It will work if the paramet=
er is=20
not implemented at all. But what happens when you try to set priority f=
or a=20
packet and use "simple" qpolicy? AFAIR nothing - you get no information=
=20
whatsoever that this parameter will not be used inside qpolicy.

And that's why we need information about parameters in /proc or /proc/s=
ys.

> If we agree on using unique strings to identify qpolicies then we can
> keep the runtime discovery much simpler. I think a manpage would be m=
ore
> helpful here, since the runtime discovery of parameters is not
> immediately obvious.
>
Manpage of what? Documentation is certainly needed but before writing o=
ne we=20
need to have a basic implementation we agree upon.
--=20
Regards,
Tomasz Grobelny
