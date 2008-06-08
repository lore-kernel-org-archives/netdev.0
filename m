From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Date: Sun, 8 Jun 2008 14:21:25 +0200
Message-ID: <200806081421.25688.tomasz@grobelny.oswiecenia.net>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806011948.39770.tomasz@grobelny.oswiecenia.net> <20080604150942.GA4980@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:2810 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761000AbYFHMVs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2008 08:21:48 -0400
In-Reply-To: <20080604150942.GA4980@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Wednesday 04 of June 2008, Gerrit Renker napisa=B3:
> | Now that I had a closer look at implementing this functionality I h=
ave a
> | few questions:
> | 1. Where should information about available qpolicies and their par=
ametrs
> | be exported? Would /proc/net/dccp/qpolicies/ be a good choice?
>
> For a sketch or a first implementation, procfs sounds like a good sta=
rting
> point.
>
> But since it is about dynamic runtime configuration, how about using =
sysfs
> or configfs instead? This is a brainstorming question, I think that s=
ysfs
> is generally preferred. I don't know how well configfs has taken off,=
 it is
> similar, but needs to be added in the configuration (under Pseudeo
> Filesystems, CONFIG_CONFIGFS_FS=3Dy|m) http://lwn.net/Articles/148973=
/
> and Documentation/filesystems/configs. But this could be done later a=
s
> well.
>
procfs has some fine example of being used for this kind of information=
,=20
namely /proc/cpuinfo and /proc/meminfo
sysfs: from sysfs-rules.txt: "(...) the sysfs interface cannot provide =
a=20
stable interface (...)"
configfs is for configuring kernel from userspace. Which is quite oppos=
ite to =20
what we want.

> | 2. I guess we should have at least one file per qpolicy with parame=
ters
> | listed inside. Like that:
> | /proc/.../qpolicies/simple: <empty>
> | /proc/.../qpolicies/prio: 1 (DCCP_SCM_PRIORITY) 2 (DCCP_SCM_TIMEOUT=
)
>
> Hm this is a "policy" question -- isn't the `timeout' policy a
> standalone variant?
>
It seems we have a bit different views on the subject. But that's to be=
=20
decided when somebody comes round to implementing timeout.

> | But we could also have qpolicy represented by directory and paramet=
ers by
> | files: /proc/.../qpolicies/simple/
> | /proc/.../qpolicies/prio/
> | /proc/.../qpolicies/prio/priority: <empty>
> | /proc/.../qpolicies/prio/timeout: <empty>
> | Which layout do you find better?
> | --
>
> I don't like the empty files. In the procfs for thinkpad Acpi
> configuration, for example, there is a line that says which commands =
are
> acceptable, similar for /sys/power/state. In that way, the (sysfs|pro=
cfs)
> file documents itself and tells the user what can be done with it. It=
 would
> be great if the qpolicies could do something similar.
>
Ok, I'll try to write a simple patch for that.
--=20
Regards,
Tomasz Grobelny
