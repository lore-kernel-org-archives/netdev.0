From: Serge Hallyn <serue@us.ibm.com>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 09 Feb 2005 08:50:59 -0600
Message-ID: <1107960659.4837.9.camel@serge>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
	 <1107958621.19262.524.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Linux Audit Discussion <linux-audit@redhat.com>
In-Reply-To: <1107958621.19262.524.camel@hades.cambridge.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-09 at 14:17 +0000, David Woodhouse wrote:
> The only time it's possibly worth verifying it is for the case where
> userspace is sending AUDIT_USER messages -- for which the process needs
> CAP_AUDIT_WRITE anyway.

CAP_AUDIT_WRITE is needed, but not CAP_AUDIT_CONTROL, which is needed to
set the loginuid.  Of course, an LSM could check at
security_netlink_send whether the login_uid in the payload is the same
as the real loginuid.  Otherwise, we're wasting a (very precious)
capability bit.

In either case, have we decided we don't want it in the netlink
credentials after all?

thanks,
-serge 
-- 
Serge Hallyn <serue@us.ibm.com>
