From: Chad Hanson <chanson@TrustedCS.com>
Subject: RE: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 09:37:28 -0500
Message-ID: <36282A1733C57546BE392885C06185927377BE@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@oss.sgi.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Linux Audit Discussion <linux-audit@redhat.com>,
        Chris Wright
	 <chrisw@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David Woodhouse wrote:
> 
> On Wed, 2005-02-09 at 16:19 -0800, Chris Wright wrote:
> > Then it comes back to the question of how to protect loginuid.  If it
> > can be spoofed by someone with CAP_AUDIT_WRITE, then it shouldn't be
> > write protected by CAP_AUDIT_CONTROL.
> 
> I'm not sure I agree with that. With CAP_AUDIT_WRITE you _can't_ modify
> the loginuid of the audit logs of your own actions. You can only modify
> the loginuid on the messages you pull out of thin air and send. You can
> already make up the rest of the payload -- why shouldn't you be allowed
> to make up the loginuid too? You could be reporting something that
> someone _else_ has done, after all.
> 

I'm not sure I understand this logic. 

Let me start with some background. The purpose of the loginuid is to record
the original creator of the process regardless of credential changes since
login. We use a capability to protect this, so it cannot be altered by most
programs, even those which write audit records. Placing the loginuid in the
payload effectively removes the purpose of CAP_AUDIT_CONTROL from all
userland audit messages. A program may be privileged to write an audit
record, but a granular security approach would not let them have the ability
to change the loginuid as well.

In your example of a process watching daemon, why would this daemon want to
spoof the credentials of the watched process? I can think of two examples.
One you are recording information for IDS like purposes of system and
process state. This could be a good use of audit, however, I don't
understand the need to make the loginuid of the audit logs match the process
you are watching. If you really did, y0ou are a heavily privileged process
already to watch all of these other processes, simply change your loginuid
through CAP_AUDIT_CONTROL and add that to the other privileges you already
have in monitoring the system state.

-Chad
