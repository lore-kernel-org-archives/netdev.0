From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 01/11] SYSCTL: export root and set handling routines
Date: Tue, 10 Jan 2012 14:39:36 -0800
Message-ID: <m1ehv76v2v.fsf@fess.ebiederm.org>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
	<20111214104449.3991.61989.stgit@localhost6.localdomain6>
	<m1bor6rg39.fsf@fess.ebiederm.org> <4EEEFC54.10700@parallels.com>
	<m18vm8g951.fsf@fess.ebiederm.org> <4EEF2C9A.8000403@parallels.com>
	<m1pqfkecw0.fsf@fess.ebiederm.org> <4EEF7364.8000407@parallels.com>
	<m1vcotigyb.fsf@fess.ebiederm.org> <4F0C150F.1020007@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust\@netapp.com" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs\@vger.kernel.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb\@suse.de" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields\@fieldses.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem\@davemloft.net" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel\@openvz.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F0C150F.1020007-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Stanislav Kinsbursky's message
	of "Tue, 10 Jan 2012 14:38:07 +0400")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> 03.01.2012 07:49, Eric W. Biederman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  writes:
>>
>>> 19.12.2011 20:37, Eric W. Biederman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>> Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>   writes:
>>>>
>>>> Doing that independently of the rest of the sysctls is pretty horr=
ible
>>>> and confusing to users.   What I am planning might suit your needs=
 and
>>>> if not we need to talk some more about how to get the vfs to do
>>>> something reasonable.
>>>>
>>>
>>> Ok, Eric. Would be glad to discuss your sysctls plans.
>>> But actually you already know my needs: I would like to make sysctl=
s work in the
>>> way like sysfs does: i.e. content of files depends on mount maker -
>>> not viewer.
>>
>> What drives the desire to have sysctls depend on the mount maker?
>
> Because we can (will, actually) have nested fs root's for containers.=
 IOW,
> container's root will be accessible from it's creator context. And I =
want to
> tune container's fs from creators context.

Tuning the child context from the parent context is an entirely
reasonable thing to do.  To affect a namespace that is not yours
the requirement is simply that we don't use current to lookup the
sysctl.  So what I am proposing should work for your case.

>> Especially what drives that desire not to have it have a /proc/<pid>=
/sys
>> directory that reflects the sysctls for a given process.
>>
>
> This is not so important for me, where to access sysctl's. But I'm wo=
rrying
> about backward compatibility. IOW, I'm afraid of changing path
> "/proc/sys/sunprc/*" to "/proc/<pid>/sys/sunrpc". This would break a =
lot of
> user-space programs.

The part that keeps it all working is by adding a symlink from /proc/sy=
s
to /proc/self/sys.  That technique has worked well for /proc/net, and I
don't expect there will be any problems with /proc/sys either.  It is
possible but is very rare for the introduction of a symlink in a path
to cause problems.

Eric

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
