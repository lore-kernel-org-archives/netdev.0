From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 9 Feb 2005 10:37:47 -0800
Message-ID: <20050209103747.Y24171@build.pdx.osdl.net>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com> <1107958621.19262.524.camel@hades.cambridge.redhat.com> <1107960659.4837.9.camel@serge> <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Linux Audit Discussion <linux-audit@redhat.com>
Content-Disposition: inline
In-Reply-To: <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil>; from sds@epoch.ncsc.mil on Wed, Feb 09, 2005 at 01:23:01PM -0500
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Stephen Smalley (sds@epoch.ncsc.mil) wrote:
> On Wed, 2005-02-09 at 09:50, Serge Hallyn wrote:
> > CAP_AUDIT_WRITE is needed, but not CAP_AUDIT_CONTROL, which is needed to
> > set the loginuid.  Of course, an LSM could check at
> > security_netlink_send whether the login_uid in the payload is the same
> > as the real loginuid.  Otherwise, we're wasting a (very precious)
> > capability bit.
> > 
> > In either case, have we decided we don't want it in the netlink
> > credentials after all?
> 
> If the audit subsystem truly needs to include the loginuid in audit
> messages generated upon processing netlink messages, then I think it
> belongs in the control buffer as per your patch.  Alexey has confirmed
> that we cannot use the current task's audit context regardless.
> 
> As a side bar, a similar security field in the control buffer would
> likewise be very useful so that SELinux could set the SID for use in
> permission checks by receive functions.

This means sendmsg hook would set the SID?  And in that case, you'd
stomp on loginuid for audit messages unless they are special cased.
The loginuid is special case to audit, it doesn't make sense to me that
it is in generic netlink_skb_parms structure unless it's used by more
netlink users.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
