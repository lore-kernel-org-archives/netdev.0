From: Stephen Smalley <sds@epoch.ncsc.mil>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 09 Feb 2005 13:40:48 -0500
Message-ID: <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
	 <1107958621.19262.524.camel@hades.cambridge.redhat.com>
	 <1107960659.4837.9.camel@serge>
	 <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209103747.Y24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Linux Audit Discussion <linux-audit@redhat.com>
In-Reply-To: <20050209103747.Y24171@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-09 at 13:37, Chris Wright wrote:
> This means sendmsg hook would set the SID?  And in that case, you'd
> stomp on loginuid for audit messages unless they are special cased.

I was referring to a separate field for use by security modules, not
re-use of the same field being proposed for the loginuid.  Yes, it would
be set by the security_netlink_send hook.  The principal problem with
such a security field is that unless we mandate it to be a simple
integer value (like a SELinux SID), we have to deal with lifecycle
management for it, i.e. a set of hooks that starts to look like the
sk_buff security hooks from the old LSM patch.  But if we can limit it
to a simple value, then it would be useful for such security
identifiers, and allow receiver-side permission checks based on the
sender SID.

> The loginuid is special case to audit, it doesn't make sense to me that
> it is in generic netlink_skb_parms structure unless it's used by more
> netlink users.

So you also think it should be in the payload?  That would require
security_netlink_send to dig into the payload if we wanted to control
who can specify other loginuids, as Serge noted.

-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency
