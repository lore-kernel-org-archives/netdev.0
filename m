From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 00/12] make rpc_pipefs be mountable multiple times
Date: Wed, 22 Dec 2010 01:32:15 +0200
Message-ID: <20101221233215.GC7092@shutemov.name>
References: <1292846078-31793-1-git-send-email-kirill@shutemov.name>
 <20101220144644.GC20643@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101220144644.GC20643-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 20, 2010 at 09:46:44AM -0500, J. Bruce Fields wrote:
> On Mon, Dec 20, 2010 at 01:54:26PM +0200, Kirill A. Shutsemov wrote:
> > From: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > 
> > Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> > Only for client for now.
> > 
> > Only quick sanity check was made. BTW, is there any check list for NFS
> > contributors?
> 
> Nothing formal.
> 
> Chuck may have some nlm patches that conflict; I'm not sure what their
> status is.
> 
> For testing rpc_pipefs, maybe a few mounts (simultaneous mounts might be
> good), possibly over different security flavors, and with some of them
> nfsv4, might be a good idea.

Ok, I'll play with it.

> By the way, was there ever a resolution to Trond's question?:
> 
> 	http://marc.info/?l=linux-nfs&m=128655758712817&w=2
> 
> 	"The keyring upcalls are currently initiated through the same
> 	mechanism as module_request and therefore get started with the
> 	init_nsproxy namespace. We'd really like them to run inside the
> 	same container as the process.  As part of the same problem,
> 	there is the issue of what to do with the dns resolver and
> 	Bryan's new keyring based idmapper code."

I'm not sure that I understand the problem correctly.

Currently, idmap uses dentry taken from client's cl_rpcclient->cl_path
(see nfs_idmap_new()). cl_rpcclient (and cl_path) is initialized with
rpcmount resolved against mount namespace of mount process (see
nfs_create_rpc_client()).
I assume it's correct.

-- 
 Kirill A. Shutemov
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
