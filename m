From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Fri, 31 Dec 2010 11:54:01 -0500
Message-ID: <1293814441.2980.4.camel@heimdal.trondhjem.org>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
	 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
	 <20101230085139.GA29697@shutemov.name> <4D1C4C7C.6050606@parallels.com>
	 <20101230094433.GB29697@shutemov.name>  <4D1C5953.6020200@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D1C5953.6020200-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-30 at 04:05 -0600, Rob Landley wrote: 
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
> /var/lib.  (Seems like policy in the kernel somehow.)  Can't it just 
> check the current process's mount list to see if an instance of 
> rpc_pipefs is mounted in the current namespace the way lxc looks for 
> cgroups?  Or are there potential performance/scalability issues with that?

The kernel doesn't give a damn about the /var/lib/nfs/rpc_pipefs bit.
That's all for the benefit of the userland utilities.

  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
