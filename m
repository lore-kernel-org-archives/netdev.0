From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
Date: Tue, 29 Nov 2011 11:40:30 -0500
Message-ID: <1322584830.4174.16.camel@lade.trondhjem.org>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
	 <20111129091037.20730.59391.stgit@localhost6.localdomain6>
	 <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com>
	 <4ED4CDCE.9080804@parallels.com>
	 <F19688880B763E40B28B2B462677FBF805E3A4AFFD@MX09A.corp.emc.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC23@SACMVEXC2-PRD.hq.netapp.com>
	 <CA+a=Yy5GKMu8rbh8y3fOtK6pmqygPNBr=a+p7LfcmTqtXFH3iA@mail.gmail.com>
	 <1322579906.3619.1.camel@lade.trondhjem.org>
	 <CA+a=Yy6kJe0NemSiRwM+t8gz5-UF5fOdwdS2so+q=nSYjBx--w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tao.peng@emc.com, skinsbursky@parallels.com,
	linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26386 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755955Ab1K2Qkg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 11:40:36 -0500
In-Reply-To: <CA+a=Yy6kJe0NemSiRwM+t8gz5-UF5fOdwdS2so+q=nSYjBx--w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-29 at 23:30 +0800, Peng Tao wrote:=20
> On Tue, Nov 29, 2011 at 11:18 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Tue, 2011-11-29 at 23:10 +0800, Peng Tao wrote:
> >> On Tue, Nov 29, 2011 at 9:35 PM, Myklebust, Trond
> >> <Trond.Myklebust@netapp.com> wrote:
> >> >> -----Original Message-----
> >> >> From: tao.peng@emc.com [mailto:tao.peng@emc.com]
> >> >> Sent: Tuesday, November 29, 2011 7:40 AM
> >> >> To: skinsbursky@parallels.com
> >> >> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; xemul@parallel=
s.com;
> >> >> neilb@suse.de; netdev@vger.kernel.org; linux-kernel@vger.kernel=
=2Eorg;
> >> >> jbottomley@parallels.com; bfields@fieldses.org; davem@davemloft=
=2Enet;
> >> >> devel@openvz.org
> >> >> Subject: RE: [PATCH 4/5] NFS: remove RPC PipeFS mount point ref=
erence
> >> >> from blocklayout routines
> >> >>
> >> >> > -----Original Message-----
> >> >> > From: Stanislav Kinsbursky [mailto:skinsbursky@parallels.com]
> >> >> > Sent: Tuesday, November 29, 2011 8:19 PM
> >> >> > To: Peng, Tao
> >> >> > Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; Pa=
vel
> >> >> > Emelianov; neilb@suse.de; netdev@vger.kernel.org;
> >> >> > linux-kernel@vger.kernel.org; James Bottomley; bfields@fields=
es.org;
> >> >> > davem@davemloft.net; devel@openvz.org
> >> >> > Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point r=
eference
> >> >> > from blocklayout routines
> >> >> >
> >> >> > 29.11.2011 16:00, tao.peng@emc.com =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
> >> >> > >> -----Original Message-----
> >> >> > >> From: linux-nfs-owner@vger.kernel.org
> >> >> > >> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of
> >> >> > Stanislav
> >> >> > >> Kinsbursky
> >> >> > >> Sent: Tuesday, November 29, 2011 6:11 PM
> >> >> > >> To: Trond.Myklebust@netapp.com
> >> >> > >> Cc: linux-nfs@vger.kernel.org; xemul@parallels.com; neilb@=
suse.de;
> >> >> > >> netdev@vger.kernel.org; linux- kernel@vger.kernel.org;
> >> >> > >> jbottomley@parallels.com; bfields@fieldses.org;
> >> >> > >> davem@davemloft.net; devel@openvz.org
> >> >> > >> Subject: [PATCH 4/5] NFS: remove RPC PipeFS mount point re=
ference
> >> >> > >> from blocklayout routines
> >> >> > >>
> >> >> > >> This is a cleanup patch. We don't need this reference anym=
ore,
> >> >> > >> because blocklayout pipes dentries now creates and destroy=
s in
> >> >> > >> per-net operations and on PipeFS mount/umount notification=
=2E
> >> >> > >> Note that nfs4blocklayout_register_net() now returns 0 ins=
tead of
> >> >> > >> -ENOENT in case of PipeFS superblock absence. This is ok, =
because
> >> >> > >> blocklayout pipe dentry will be created on PipeFS mount ev=
ent.
> >> >> > > When is the "pipefs mount event" going to happen? When inse=
rting
> >> >> > > kernel modules or when user issues
> >> >> > mount command?
> >> >> > >
> >> >> >
> >> >> > When user issues mount command.
> >> >> > Kernel mounts of PipeFS has been removed with all these patch=
 sets
> >> >> > I've sent already.
> >> >> Then it is going to break blocklayout user space program blkmap=
d, which is
> >> >> stared before mounting any file system and it tries to open the=
 pipe file
> >> >> when started.
> >> >
> >> > Why on earth is blkmapd doing this instead of listening for file=
 creation notifications like the other rpc_pipefs daemons do?
> >> Not sure how the original implementer chose this but I think it is
> >> likely because we do not expect the pipe file to be created or del=
eted
> >> dynamically.
> >
> > Unless blkmapd can pin the sunrpc module (which it shouldn't be abl=
e to)
> > then that assumption would be wrong. Please look into fixing blkmap=
d...
> Sorry, I don't quite get it. Do you mean sunrpc module may be removed
> while nfs/blocklayout modules are still in use? Please explain it a
> bit. Thanks.

I mean that I'm perfectly entitled to do

'modprobe -r blocklayoutdriver'

and when I do that, then I expect blkmapd to close the rpc pipe and wai=
t
for a new one to be created just like rpc.idmapd and rpc.gssd do when I
remove the nfs and sunrpc modules.

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
