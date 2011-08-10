From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 1/6] Security: define security_sk_getsecid.
Date: Wed, 10 Aug 2011 08:49:53 -0400
Message-ID: <1312980593.21048.12.camel@moss-pluto>
References: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com>
	 <1312874910-31010-2-git-send-email-rongqing.li@windriver.com>
	 <4E415CB3.8020202@schaufler-ca.com> <4E41D421.1000302@windriver.com>
	 <4E41D78C.7040007@schaufler-ca.com>  <4E41DDEB.9040904@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org
To: Rongqing Li <rongqing.li@windriver.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4E41DDEB.9040904@windriver.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-08-10 at 09:24 +0800, Rongqing Li wrote:
> On 08/10/2011 08:57 AM, Casey Schaufler wrote:
> > On 8/9/2011 5:43 PM, Rongqing Li wrote:
> >> On 08/10/2011 12:13 AM, Casey Schaufler wrote:
> >>> On 8/9/2011 12:28 AM, rongqing.li@windriver.com wrote:
> >>>> From: Roy.Li<rongqing.li@windriver.com>
> >>>>
> >>>> Define security_sk_getsecid to get the security id of a sock.
> >>>
> >>> Why are you requesting the secid when you're just going to
> >>> use it to get the secctx? Why not ask for that directly?
> >>> Is there ever a case where you only want the secid?
> >>>
> >> Hi:
> >>
> >> As I know, we have not method to get secctx directly.
> >
> > You are defining the method! Ask for what you want!
> >
> > The whole notion of secids is a holdover from the bad old
> > days when SELinux was a user space based enforcement mechanism.
> > The audit system was implemented when SELinux was the lone LSM
> > and unfortunately and unnecessarily propagated the use of secids.
> > If an object has a secid it must also have a secctx. The
> > interfaces that use secids could just as well use the secctx.
> > It is wasteful to create a new interface that fetches a secid
> > just to turn around and ask for the secctx in all cases.
> >
> 
> Do you means I should write a method like below
> security_sk_getsecctx(struct sock *sk, char *secctx, int *len)?
> 
> But secctx only is used to user. secid is used to source code to
> compute and compare the access permission.
> 
> And I do not see the same method like
> security_task_getsecctx(). but security_task_getsecid() has been
> implemented in kernel source code.

Unlike Casey, I don't think secids are a bad idea or just a holdover -
we find them to be quite useful and efficient in SELinux.  But in this
instance, he is correct that there is no reason to first fetch a secid
only to convert it into a context.  There are other cases where you do
in fact want to avoid generating and managing the life cycle of a
security context string until you truly need it, and thus a secid makes
sense.  So if you want to add a security_sk_getsecctx() hook, feel free.
There are some existing examples, e.g. security_inode_getsecctx() for
inodes, security_getprocattr() for tasks.  Note that they use a slightly
different interface than what you describe above.

-- 
Stephen Smalley
National Security Agency

