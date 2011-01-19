From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: netconsole build breakage (Re: [GIT] Networking)
Date: Wed, 19 Jan 2011 02:33:51 -0800
Message-ID: <1295433231.21351.17.camel@haakon2.linux-iscsi.org>
References: <20110114.130323.201674039.davem@davemloft.net>
	 <20110119095920.GA10543@elte.hu> <20110119100824.GD9903@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@suse.de>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joel Becker <jlbec@evilplan.org>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110119100824.GD9903@cr0.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-01-19 at 18:08 +0800, Am=C3=A9rico Wang wrote:
> On Wed, Jan 19, 2011 at 10:59:20AM +0100, Ingo Molnar wrote:
> >
> >FYI, there's a .38-rc1 build failure that triggers rather often:
> >
> > drivers/built-in.o: In function `drop_netconsole_target':
> > netconsole.c:(.text+0x130146): undefined reference to `config_item_=
put'
> > drivers/built-in.o: In function `write_msg':
> > netconsole.c:(.text+0x1301aa): undefined reference to `config_item_=
get'
> > netconsole.c:(.text+0x130217): undefined reference to `config_item_=
put'
> > drivers/built-in.o: In function `netconsole_netdev_event':
> > netconsole.c:(.text+0x1302ab): undefined reference to `config_item_=
get'
> > ...
> >
> >Triggered by this configuration:
> >
> > CONFIG_CONFIGFS_FS=3Dm
> > CONFIG_NETCONSOLE=3Dy
> >
>=20
> Should be "depends on CONFIGFS_FS=3Dy".

Sorry for breaking this one folks..

Where this was left yesterday was to change NETCONSOLE_DYNAMIC, DLM and
OCFS2_FS symbols to use 'select configfs' instead of 'depends on SYSFS
&& CONFIGFS':

http://marc.info/?l=3Dlinux-kernel&m=3D129539400709508&w=3D2

but unfortuately this did not make it into .38-rc1 in time..

Using 'select CONFIGFS_FS' here for NETCONSOLE_DYNAMIC with the
following patches should do the trick.

   git://git.kernel.org/pub/scm/linux/kernel/git/nab/scsi-post-merge-2.=
6.git for-linus

Thanks,

Nicholas Bellinger (3):
  net: Make NETCONSOLE_DYNAMIC use select CONFIGFS_FS
  dlm: Make DLM use select CONFIGFS_FS
  ocfs2: Make OCFS2_FS use select CONFIGFS_FS

 drivers/net/Kconfig |    3 ++-
 fs/dlm/Kconfig      |    4 ++--
 fs/ocfs2/Kconfig    |    3 ++-
 3 files changed, 6 insertions(+), 4 deletions(-)
