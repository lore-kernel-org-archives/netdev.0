From: Klaus Weidner <klaus@atsec.com>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 11:52:21 -0600
Message-ID: <20050210175221.GA13458@w-m-p.com>
References: <36282A1733C57546BE392885C06185927377BE@chaos.tcs.tcs-sec.com> <1108047396.19262.537.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: kuznet@ms2.inr.ac.ru, davem@davemloft.net, netdev@oss.sgi.com
To: Linux Audit Discussion <linux-audit@redhat.com>
Content-Disposition: inline
In-Reply-To: <1108047396.19262.537.camel@hades.cambridge.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 10, 2005 at 02:56:36PM +0000, David Woodhouse wrote:
> On Thu, 2005-02-10 at 09:37 -0500, Chad Hanson wrote:
> > In your example of a process watching daemon, why would this daemon w=
ant to
> > spoof the credentials of the watched process? I can think of two exam=
ples.
>=20
> Perhaps I misunderstand the intent of userspace AUDIT_WRITE. Can you
> provide examples of why you _wouldn't_ want to let a d=E6mon which is
> already sending random unvetted AUDIT_WRITE messages also specify the
> loginuid on _those_ messages?

A few comments on this issue from the point of view of common criteria
evaluations... Briefly, either choice of implementation would be okay.

Both CAPP and LSPP assume trustworthy administrators, and those
protection profiles don't really support the concept of fine grained
capabilities for not-quite-administrator tasks.

The CAPP and LSPP audit requirements include that audit records contain
the subject identity, this corresponds to the login UID. The point of the
user messages is to support proper auditing of actions that aren't
directly related to system calls, such as authenticating users, modifying
security databases, and similar things. This is always done by trusted
processes, so the technical method used to get the login UID into the
audit record for user messages doesn't matter as long as it can't be
falsified by non-administrators.

A CAPP/LSPP compliant implementation could for example completely bypass
the kernel and append user messages from trusted processes directly to
the audit log file - I'm not saying that would be a good idea, but it
could be compliant.

-Klaus
