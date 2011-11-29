From: Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
Date: Tue, 29 Nov 2011 23:30:22 +0800
Message-ID: <CA+a=Yy6kJe0NemSiRwM+t8gz5-UF5fOdwdS2so+q=nSYjBx--w@mail.gmail.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
 <20111129091037.20730.59391.stgit@localhost6.localdomain6>
 <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com>
 <4ED4CDCE.9080804@parallels.com> <F19688880B763E40B28B2B462677FBF805E3A4AFFD@MX09A.corp.emc.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC23@SACMVEXC2-PRD.hq.netapp.com>
 <CA+a=Yy5GKMu8rbh8y3fOtK6pmqygPNBr=a+p7LfcmTqtXFH3iA@mail.gmail.com> <1322579906.3619.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tao.peng@emc.com, skinsbursky@parallels.com,
	linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:60926 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671Ab1K2Pao convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 10:30:44 -0500
In-Reply-To: <1322579906.3619.1.camel@lade.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 11:18 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Tue, 2011-11-29 at 23:10 +0800, Peng Tao wrote:
>> On Tue, Nov 29, 2011 at 9:35 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>> >> -----Original Message-----
>> >> From: tao.peng@emc.com [mailto:tao.peng@emc.com]
>> >> Sent: Tuesday, November 29, 2011 7:40 AM
>> >> To: skinsbursky@parallels.com
>> >> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; xemul@parallels.=
com;
>> >> neilb@suse.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.o=
rg;
>> >> jbottomley@parallels.com; bfields@fieldses.org; davem@davemloft.n=
et;
>> >> devel@openvz.org
>> >> Subject: RE: [PATCH 4/5] NFS: remove RPC PipeFS mount point refer=
ence
>> >> from blocklayout routines
>> >>
>> >> > -----Original Message-----
>> >> > From: Stanislav Kinsbursky [mailto:skinsbursky@parallels.com]
>> >> > Sent: Tuesday, November 29, 2011 8:19 PM
>> >> > To: Peng, Tao
>> >> > Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; Pave=
l
>> >> > Emelianov; neilb@suse.de; netdev@vger.kernel.org;
>> >> > linux-kernel@vger.kernel.org; James Bottomley; bfields@fieldses=
=2Eorg;
>> >> > davem@davemloft.net; devel@openvz.org
>> >> > Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point ref=
erence
>> >> > from blocklayout routines
>> >> >
>> >> > 29.11.2011 16:00, tao.peng@emc.com =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>> >> > >> -----Original Message-----
>> >> > >> From: linux-nfs-owner@vger.kernel.org
>> >> > >> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of
>> >> > Stanislav
>> >> > >> Kinsbursky
>> >> > >> Sent: Tuesday, November 29, 2011 6:11 PM
>> >> > >> To: Trond.Myklebust@netapp.com
>> >> > >> Cc: linux-nfs@vger.kernel.org; xemul@parallels.com; neilb@su=
se.de;
>> >> > >> netdev@vger.kernel.org; linux- kernel@vger.kernel.org;
>> >> > >> jbottomley@parallels.com; bfields@fieldses.org;
>> >> > >> davem@davemloft.net; devel@openvz.org
>> >> > >> Subject: [PATCH 4/5] NFS: remove RPC PipeFS mount point refe=
rence
>> >> > >> from blocklayout routines
>> >> > >>
>> >> > >> This is a cleanup patch. We don't need this reference anymor=
e,
>> >> > >> because blocklayout pipes dentries now creates and destroys =
in
>> >> > >> per-net operations and on PipeFS mount/umount notification.
>> >> > >> Note that nfs4blocklayout_register_net() now returns 0 inste=
ad of
>> >> > >> -ENOENT in case of PipeFS superblock absence. This is ok, be=
cause
>> >> > >> blocklayout pipe dentry will be created on PipeFS mount even=
t.
>> >> > > When is the "pipefs mount event" going to happen? When insert=
ing
>> >> > > kernel modules or when user issues
>> >> > mount command?
>> >> > >
>> >> >
>> >> > When user issues mount command.
>> >> > Kernel mounts of PipeFS has been removed with all these patch s=
ets
>> >> > I've sent already.
>> >> Then it is going to break blocklayout user space program blkmapd,=
 which is
>> >> stared before mounting any file system and it tries to open the p=
ipe file
>> >> when started.
>> >
>> > Why on earth is blkmapd doing this instead of listening for file c=
reation notifications like the other rpc_pipefs daemons do?
>> Not sure how the original implementer chose this but I think it is
>> likely because we do not expect the pipe file to be created or delet=
ed
>> dynamically.
>
> Unless blkmapd can pin the sunrpc module (which it shouldn't be able =
to)
> then that assumption would be wrong. Please look into fixing blkmapd.=
=2E.
Sorry, I don't quite get it. Do you mean sunrpc module may be removed
while nfs/blocklayout modules are still in use? Please explain it a
bit. Thanks.

Best,
Tao
>
> =C2=A0 Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>



--=20
Thanks,
Tao
