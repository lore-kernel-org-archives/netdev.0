From: Ingo Molnar <mingo@elte.hu>
Subject: Re: netconsole build breakage (Re: [GIT] Networking)
Date: Wed, 19 Jan 2011 11:57:08 +0100
Message-ID: <20110119105708.GA16722@elte.hu>
References: <20110114.130323.201674039.davem@davemloft.net>
 <20110119095920.GA10543@elte.hu>
 <20110119100824.GD9903@cr0.nay.redhat.com>
 <1295433231.21351.17.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@suse.de>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joel Becker <jlbec@evilplan.org>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1295433231.21351.17.camel@haakon2.linux-iscsi.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Nicholas A. Bellinger <nab@linux-iscsi.org> wrote:

> On Wed, 2011-01-19 at 18:08 +0800, Am=E9rico Wang wrote:
> > On Wed, Jan 19, 2011 at 10:59:20AM +0100, Ingo Molnar wrote:
> > >
> > >FYI, there's a .38-rc1 build failure that triggers rather often:
> > >
> > > drivers/built-in.o: In function `drop_netconsole_target':
> > > netconsole.c:(.text+0x130146): undefined reference to `config_ite=
m_put'
> > > drivers/built-in.o: In function `write_msg':
> > > netconsole.c:(.text+0x1301aa): undefined reference to `config_ite=
m_get'
> > > netconsole.c:(.text+0x130217): undefined reference to `config_ite=
m_put'
> > > drivers/built-in.o: In function `netconsole_netdev_event':
> > > netconsole.c:(.text+0x1302ab): undefined reference to `config_ite=
m_get'
> > > ...
> > >
> > >Triggered by this configuration:
> > >
> > > CONFIG_CONFIGFS_FS=3Dm
> > > CONFIG_NETCONSOLE=3Dy
> > >
> >=20
> > Should be "depends on CONFIGFS_FS=3Dy".
>=20
> Sorry for breaking this one folks..
>=20
> Where this was left yesterday was to change NETCONSOLE_DYNAMIC, DLM a=
nd
> OCFS2_FS symbols to use 'select configfs' instead of 'depends on SYSF=
S
> && CONFIGFS':
>=20
> http://marc.info/?l=3Dlinux-kernel&m=3D129539400709508&w=3D2
>=20
> but unfortuately this did not make it into .38-rc1 in time..
>=20
> Using 'select CONFIGFS_FS' here for NETCONSOLE_DYNAMIC with the
> following patches should do the trick.
>=20
>    git://git.kernel.org/pub/scm/linux/kernel/git/nab/scsi-post-merge-=
2.6.git for-linus
>=20
> Thanks,
>=20
> Nicholas Bellinger (3):
>   net: Make NETCONSOLE_DYNAMIC use select CONFIGFS_FS
>   dlm: Make DLM use select CONFIGFS_FS
>   ocfs2: Make OCFS2_FS use select CONFIGFS_FS
>=20
>  drivers/net/Kconfig |    3 ++-

Yeah, using select CONFIGFS_FS (and removing the SYSFS and CONFIGFS_FS =
dependencies)=20
is the correct and clean solution here.

Thanks,

	Ingo
