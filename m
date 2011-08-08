From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 1/5] Define the function to write sock's security
 context to seq_file.
Date: Mon, 08 Aug 2011 09:25:36 -0400
Message-ID: <1312809936.324.8.camel@moss-pluto>
References: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
	 <1312534686-4099-2-git-send-email-rongqing.li@windriver.com>
	 <1312552618.19283.51.camel@moss-pluto>  <4E3FAD40.1020404@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	lsm <linux-security-module@vger.kernel.org>
To: Rongqing Li <rongqing.li@windriver.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4E3FAD40.1020404@windriver.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-08-08 at 17:32 +0800, Rongqing Li wrote:
> On 08/05/2011 09:56 PM, Stephen Smalley wrote:
> > I'm not sure it is a good idea to output nothing if permission is denied
> > to the socket, as opposed to some well-defined string indicating that
> > condition.  Particularly if someone later adds another field to
> > the /proc files after the context; we don't want the contents of that
> > field to be interpreted as the context if permission was denied.
> >
> 
>  From your review, I redesign the output information as below.
> 
> when disable SELinux, print "(none)" in proc
> when enable  SELinux, no error on getting security context, print the 
> real security context
> when enable  SELinux, there is error on getting security context, print 
> "??"
> 
> Do you think it is OK?

It appears that netstat presently displays a "-" if it cannot obtain the
security context or pid/program name information, so perhaps you should
follow that convention whenever you cannot obtain a security context
regardless of the particular reason. Note that your logic shouldn't be
based on whether or not SELinux is enabled/disabled per se, but rather
based on whether the security module provides security contexts, which
can be determined by checking whether the secid is set to a non-zero
value by security_sk_getsecid().  The audit system (kernel/audit*.c)
uses similar logic to decide whether or not to log task security
contexts.

-- 
Stephen Smalley
National Security Agency

