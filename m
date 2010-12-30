From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Thu, 30 Dec 2010 12:44:16 +0200
Message-ID: <20101230104416.GA31824@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
 <20101230085139.GA29697@shutemov.name>
 <4D1C4C7C.6050606@parallels.com>
 <20101230094433.GB29697@shutemov.name>
 <4D1C5953.6020200@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D1C5953.6020200-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 30, 2010 at 04:05:07AM -0600, Rob Landley wrote:
> On 12/30/2010 03:44 AM, Kirill A. Shutemov wrote:
> >>> If no rpcmount mountoption, no rpc_pipefs was found at
> >>> '/var/lib/nfs/rpc_pipefs' and we are in init's mount namespace, we use
> >>> init_rpc_pipefs.
> >>
> >> It's the "we are in init's mount namespace" that I was wondering about.
> >>
> >> So if I naievely chroot, nfs mount stops working the way it did before I
> >> chrooted unless I do an extra setup step?
> >
> > No. It will work as before since you are still in init's mount namespace.
> > Creating new mount namespace changes rules.
> 
> Ah, CLONE_NEWNS and then you need /var/lib/nfs/rpc_pipefs.  Got it.
> 
> I'm kind of surprised that the kernel cares about a specific path under 
> /var/lib.  (Seems like policy in the kernel somehow.)

Yep. It's bad, but there is way to overwrite the default.

Other way is to leave 'rpcmount' mountoption without default.
get_rpc_pipefs(NULL) in init's mount namespace will always return
init_rpc_pipefs, without filesystem lookup.
get_rpc_pipefs(NULL) in non-init's mount namespace will always return
error.

So you will have to specify 'rpcmount' mountoption for every nfs mount in
container. Hmm, I guess, it may confuse user.

Or we can try to move the default to userspace. /sbin/mount.nfs?

> Can't it just 
> check the current process's mount list to see if an instance of 
> rpc_pipefs is mounted in the current namespace the way lxc looks for 
> cgroups?  Or are there potential performance/scalability issues with that?

What should we do if we have several rpc_pipefs mounts in the namespace?

-- 
 Kirill A. Shutemov
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
