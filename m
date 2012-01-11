From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
Date: Wed, 11 Jan 2012 11:23:23 -0500
Message-ID: <1326299003.17212.7.camel@lade.trondhjem.org>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
		 <1325285705.10984.4.camel@lade.trondhjem.org>
	 <1325797111.11084.22.camel@lade.trondhjem.org>
	 <4F0C35F3.7060508@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F0C35F3.7060508-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-01-10 at 16:58 +0400, Stanislav Kinsbursky wrote:=20
> 06.01.2012 00:58, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > The second problem that was highlighted was the fact that as they s=
tand
> > today, these patchsets do not allow for bisection. When we hit the =
Oops,
> > I had Bryan try to bisect where the problem arose. He ended up poin=
ting
> > at the patch "SUNRPC: handle RPC client pipefs dentries by network
> > namespace aware routine", which is indeed the cause, but which is o=
ne of
> > the _dependencies_ for all the PipeFS notifier patches that fix the
> > problem.
> >
>=20
> I'm confused here. Does this means, that I have to fix patch "SUNRPC:=
 handle RPC=20
> client pipefs dentries by network namespace aware routine" to make it=
 able to=20
> bisect?

What I mean is that currently, I have various ways to Oops the kernel
when I apply "SUNRPC: handle RPC client pipefs dentries by network
namespace aware routine" before all these other followup patches are
applied.

One way to could fix this, might be to add dummy versions of
rpc_pipefs_notifier_register()/unregister() so that "NFS: idmap PipeFS
notifier introduced" and the other such patches can be applied without
compilation errors or Oopses before the "handle RPC client pipefs
dentries..." patch is applied. The latter could then enable the real
rpc_pipefs_notifier_register()/....

The point is to not have these patches add _known_ bugs to the kernel a=
t
any point, so that someone who is trying to track down an unknown bug
via "git bisect" doesn't have to also cope with these avoidable
issues...

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
