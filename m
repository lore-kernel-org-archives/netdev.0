From: Stephen Smalley <sds@epoch.ncsc.mil>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 09 Feb 2005 13:23:01 -0500
Message-ID: <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
	 <1107958621.19262.524.camel@hades.cambridge.redhat.com>
	 <1107960659.4837.9.camel@serge>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Linux Audit Discussion <linux-audit@redhat.com>
In-Reply-To: <1107960659.4837.9.camel@serge>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-09 at 09:50, Serge Hallyn wrote:
> CAP_AUDIT_WRITE is needed, but not CAP_AUDIT_CONTROL, which is needed to
> set the loginuid.  Of course, an LSM could check at
> security_netlink_send whether the login_uid in the payload is the same
> as the real loginuid.  Otherwise, we're wasting a (very precious)
> capability bit.
> 
> In either case, have we decided we don't want it in the netlink
> credentials after all?

If the audit subsystem truly needs to include the loginuid in audit
messages generated upon processing netlink messages, then I think it
belongs in the control buffer as per your patch.  Alexey has confirmed
that we cannot use the current task's audit context regardless.

As a side bar, a similar security field in the control buffer would
likewise be very useful so that SELinux could set the SID for use in
permission checks by receive functions.

-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency
