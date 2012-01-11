From: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 01/11] SYSCTL: export root and set handling routines
Date: Wed, 11 Jan 2012 22:02:16 +0400
Message-ID: <4F0DCEA8.7040205@parallels.com>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>	<20111214104449.3991.61989.stgit@localhost6.localdomain6>	<m1bor6rg39.fsf@fess.ebiederm.org> <4EEEFC54.10700@parallels.com>	<m18vm8g951.fsf@fess.ebiederm.org> <4EEF2C9A.8000403@parallels.com>	<m1pqfkecw0.fsf@fess.ebiederm.org> <4EEF7364.8000407@parallels.com>	<m1vcotigyb.fsf@fess.ebiederm.org> <4F0C150F.1020007@parallels.com>	<m1ehv76v2v.fsf@fess.ebiederm.org> <4F0D5A9E.5030501@parallels.com> <m1sjjm40k8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m1sjjm40k8.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

11.01.2012 21:21, Eric W. Biederman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>> Especially what drives that desire not to have it have a /proc/<p=
id>/sys
>>>>> directory that reflects the sysctls for a given process.
>>>>>
>>>>
>>>> This is not so important for me, where to access sysctl's. But I'm=
 worrying
>>>> about backward compatibility. IOW, I'm afraid of changing path
>>>> "/proc/sys/sunprc/*" to "/proc/<pid>/sys/sunrpc". This would break=
 a lot of
>>>> user-space programs.
>>>
>>> The part that keeps it all working is by adding a symlink from /pro=
c/sys
>>> to /proc/self/sys.  That technique has worked well for /proc/net, a=
nd I
>>> don't expect there will be any problems with /proc/sys either.  It =
is
>>> possible but is very rare for the introduction of a symlink in a pa=
th
>>> to cause problems.
>>>
>>
>> Probably I don't understand you, but as I see it now, symlink to "/p=
roc/self/"
>> is unacceptable because of the following:
>> 1) will be used current context (any) instead of desired one
> (Using the current context is the desirable outcome for existing tool=
s).
>> 1) if CT has other pid namespace - then we just have broken link.
>
> Assuming the process in question is not in the pid namespace availabl=
e
> to proc then yes you will indeed have a broken link.  But a broken
> link is only a problem for new applications that are doing something =
strange.
>

I believe, that container is assuming to work in  it's own network and =
pid=20
namespaces.
With your approach, if I'm not mistaken, container's /proc/net and /pro=
c/sys=20
tunables will be unaccessible from parent environment. Or I'm wrong her=
e?

> I am proposing treating /proc/sys like /proc/net has already been
> treated.  Aka move have the version of /proc/sys that relative to a
> process be visible at: /proc/<pid>/sys, and with a compat symlink
> from /proc/sys ->  /proc/self/sys.
>
> Just like has already been done with /proc/net.
>

1) On one hand it looks logical, that any nested dentries in /proc are =
tied to=20
pid namespace. But on the other hand we have a lot of tunables in /proc=
/net,=20
/proc/sys, etc. which have nothing with processes or whatever similar.
2) currently /proc processes directories (i.e. /proc/1/, etc) depends o=
n mount=20
maker context. But /proc/sys and /proc/net doesn't. This looks weird an=
d=20
despondently, from my pow. What do you think about it?

And what do you think about "conteinerization" of /proc contents in the=
 way like=20
"sysfs" was done?
Implementing /proc "conteinerization" in this way can give us great fle=
xibility.
=46or example, /proc/net (and /proc/sys/sunrpc) depends on mount owner =
net=20
namespace, /proc/sysvipc depends on mount owner ipc namespace, etc.
And this approach doesn't break backward compatibility as well.

> Semantically this should be easy to understand, and about as backward=
s
> compatible as it gets.
>
> Eric


--=20
Best regards,
Stanislav Kinsbursky
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
