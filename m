From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 09 Feb 2005 23:56:09 +0000
Message-ID: <1107993369.9154.2.camel@localhost.localdomain>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
	 <1107958621.19262.524.camel@hades.cambridge.redhat.com>
	 <1107960659.4837.9.camel@serge>
	 <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209103747.Y24171@build.pdx.osdl.net>
	 <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209153816.B24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Smalley <sds@epoch.ncsc.mil>, netdev@oss.sgi.com,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Linux Audit Discussion <linux-audit@redhat.com>
In-Reply-To: <20050209153816.B24171@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-09 at 15:38 -0800, Chris Wright wrote:
>> So you also think it should be in the payload?  That would require
>> security_netlink_send to dig into the payload if we wanted to control
>> who can specify other loginuids, as Serge noted.
>
>I just don't see it making sense to add another credential for a special
>case.  The signal code already peaks into the siginfo struct when queuei=
ng
>a signal to make sure some user isn't trying to send si_code =3D=3D SI_K=
ERNEL
>or similar.  Perhaps audit could do that with it's own payload during se=
nd.
>No matter how we slice it, it's a special case.

I'm not entirely sure the check is needed anyway. This is a trusted
application sending audit messages. Why shouldn't it be permitted to log
auditable events which were triggered by someone _else_?=20

If we want to audit the actions of the userspace logging d=C3=A6mon itsel=
f
and see what it sends, then we can quite happily do so within the audit
framework. That's a _different_ issue, surely?

--=20
dwmw2
