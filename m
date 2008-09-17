From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Wed, 17 Sep 2008 15:11:43 -0700
Message-ID: <20080917151143.debb6adc.akpm@linux-foundation.org>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	<1221483926.30816.18.camel@moss-spartans.epoch.ncsc.mil>
	<20080917125053.1f9ecf37.akpm@linux-foundation.org>
	<200809171724.36269.paul.moore@hp.com>
	<m1vdwu4fku.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paul.moore-VXdhtT5mjnY@public.gmane.org, sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
	rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m1vdwu4fku.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Sep 2008 14:39:45 -0700
ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) wrote:

> Paul Moore <paul.moore-VXdhtT5mjnY@public.gmane.org> writes:
> 
> > We suck?  Maybe, but some explanation about why we suck in this 
> > particular case would be helpful as far as I'm concerned.  I don't 
> > really care about identifying the guilty suckees, I'm more interested 
> > in finding out what happened to cause us to suck because of this.
> 
> Agreed.  I believe we carefully gave selinux the same paths for /proc/net
> that it had before so I don't know why this affects user space.
> 
> I know we had some selinux review when we made the change.
> 
> Eric

It's back up-thread somewhere.  umm...

On Mon, 15 Sep 2008 09:05:26 -0400
Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org> wrote:

> However, the most likely explanation is simply that when /proc/net was
> changed from being a directory to being a symlink to /proc/self/net,
> that introduced an additional permission check on accesses
> of /proc/net/<whatever>, namely the read check on the symlink itself.
> And since that check wasn't happening on /proc/net accesses with older
> kernels, older policies didn't allow it.
