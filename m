From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
Date: Sat, 10 Mar 2012 13:01:52 -0600
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA81A8AB3C07@MNEXMB1.qlogic.org>
References: <1330789663-30481-1-git-send-email-santoshprasadnayak@gmail.com>
	<13A253B3F9BEFE43B93C09CF75F63CAA81A8AB3B75@MNEXMB1.qlogic.org>
 <CAOD=uF7=28Bx4eSpGfP-uTND42k1xKE3tvQ6+exSJha9Yjf-_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: santosh prasad nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOD=uF7=28Bx4eSpGfP-uTND42k1xKE3tvQ6+exSJha9Yjf-_w@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: santosh prasad nayak [mailto:santoshprasadnayak@gmail.com]
> Sent: Saturday, March 10, 2012 12:20 AM
> To: Rajesh Borundia
> Cc: Sony Chacko; netdev; linux-kernel; kernel-janitors@vger.kernel.or=
g
> Subject: Re: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
>=20
> On Fri, Mar 9, 2012 at 10:04 PM, Rajesh Borundia
> <rajesh.borundia@qlogic.com> wrote:
> >
> >> -----Original Message-----
> >> From: santosh nayak [mailto:santoshprasadnayak@gmail.com]
> >> Sent: Saturday, March 03, 2012 9:18 PM
> >> To: Sony Chacko
> >> Cc: Rajesh Borundia; netdev; linux-kernel; kernel-
> >> janitors@vger.kernel.org; Santosh Nayak
> >> Subject: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
> >>
> >> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> >>
> >> Fix endian bug.
> >>
> >> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> >> ---
> >> =A0drivers/net/ethernet/qlogic/netxen/netxen_nic.h =A0 =A0| =A0 =A0=
4 ++--
> >> =A0drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c | =A0 12 +++=
++++--
> ---
> >> =A0.../net/ethernet/qlogic/netxen/netxen_nic_main.c =A0 | =A0 =A02=
 +-
> >> =A03 files changed, 10 insertions(+), 8 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
> >> b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
> >> index 2eeac32..b5de8a7 100644
> >> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
> >> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
> >> @@ -954,7 +954,7 @@ typedef struct nx_mac_list_s {
> >>
> >> =A0struct nx_vlan_ip_list {
> >> =A0 =A0 =A0 struct list_head list;
> >> - =A0 =A0 u32 ip_addr;
> >> + =A0 =A0 __be32 ip_addr;
> >> =A0};
> >>
> >> =A0/*
> >> @@ -1780,7 +1780,7 @@ int netxen_process_rcv_ring(struct
> >> nx_host_sds_ring *sds_ring, int max);
> >> =A0void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
> >> =A0int netxen_config_intr_coalesce(struct netxen_adapter *adapter)=
;
> >> =A0int netxen_config_rss(struct netxen_adapter *adapter, int enabl=
e);
> >> -int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip,
> int
> >> cmd);
> >> +int netxen_config_ipaddr(struct netxen_adapter *adapter, __be32 i=
p,
> >> int cmd);
> >> =A0int netxen_linkevent_request(struct netxen_adapter *adapter, in=
t
> >> enable);
> >> =A0void netxen_advert_link_change(struct netxen_adapter *adapter, =
int
> >> linkup);
> >> =A0void netxen_pci_camqm_read_2M(struct netxen_adapter *, u64, u64=
 *);
> >> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> >> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> >> index 6f37470..0f81287 100644
> >> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> >> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> >> @@ -909,10 +909,11 @@ int netxen_config_rss(struct netxen_adapter
> >> *adapter, int enable)
> >> =A0 =A0 =A0 return rv;
> >> =A0}
> >>
> >> -int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip,
> int
> >> cmd)
> >> +int netxen_config_ipaddr(struct netxen_adapter *adapter, __be32 i=
p,
> >> int cmd)
> >> =A0{
> >> =A0 =A0 =A0 nx_nic_req_t req;
> >> =A0 =A0 =A0 u64 word;
> >> + =A0 =A0 u64 ip_addr;
> >> =A0 =A0 =A0 int rv;
> >>
> >> =A0 =A0 =A0 memset(&req, 0, sizeof(nx_nic_req_t));
> >> @@ -922,7 +923,8 @@ int netxen_config_ipaddr(struct netxen_adapter
> >> *adapter, u32 ip, int cmd)
> >> =A0 =A0 =A0 req.req_hdr =3D cpu_to_le64(word);
> >>
> >> =A0 =A0 =A0 req.words[0] =3D cpu_to_le64(cmd);
> >> - =A0 =A0 req.words[1] =3D cpu_to_le64(ip);
> >> + =A0 =A0 ip_addr =3D be32_to_cpu(ip);
> >> + =A0 =A0 *(__be64 *)&req.words[1] =3D cpu_to_be64(ip_addr);
> >
>=20
>=20
> > Adapter requires ip value in big endian stored at lower 32 bit
> address.
> > The cpu_to_be64 will swap the lower 32 bit with higher 32 bit and
> adapter
> > Will get incorrect ip addr. Instead u can do.
> >
> > =A0 =A0 =A0 U32 *ip_addr;
> > =A0 =A0 =A0 ip_addr =3D (u32 *)&req.words[1];
> > =A0 =A0 =A0 *ip_addr =3D ip;
>=20
>=20
> 1.  It looks incomplete.
>     In the function call "netxen_send_cmd_descs" we have to pass "&re=
q"
> as
>    2nd argument  not  "ipaddr".

 I should have sent a patch. This piece of code was just to show how to
copy ip addr in  req.words[1].

>=20
> 2. Your above suggestion is with assumption that the data type of 2nd
> argument "ip"
>      in "netxen_config_ipaddr()" is still "u32".  This is not true.
>=20
>      Some days back you suggested to change the data type to "__be32"=
=2E
>  In the present patch
>      the "ip"  is in "__be32" format i.e already in Big endian format
> as per requirement.
>      We need to only convert this 32 bit to 64 bit.  There are two
> ways:
>=20
 No I did not assume that ip is u32, ip is still __be32(ip value is in =
form of big endian)
 though I should have mentioned it explicitly. But the ip value should =
be copied to lower 32 bit of req.words[1].
=20
   =20
>      a.   *(__be64 *)&req.words[1] =3D ip;   // auto conversion
In big endian machine MSB is copied into MSB first. So ip will get copi=
ed into higher 32 bit of
req.words[1] but adapter requires it in lower 32 bit.=20
>=20
>      b.   *(__be64 *)&req.words[1] =3D cpu_to_be64(be32_to_cpu(ip));
>             // explicit conversion.
>=20
If you follow second cpu_to_be64 it will swap lower 32 bit of ip with h=
igher 32 bit in little endian machine.
But adapter requires it in lower 32 bit.

Simple solution to copy ip in req.words[1] could be memcpy(&req.words[1=
], &ip, sizeof(u32));

=20
>=20
>  Please correct me if I am wrong.
>=20
>=20
> regards
> Santosh
>=20
>=20
>=20
>=20
> >
> >
> >>
> >> =A0 =A0 =A0 rv =3D netxen_send_cmd_descs(adapter, (struct cmd_desc=
_type0
> >> *)&req, 1);
> >> =A0 =A0 =A0 if (rv !=3D 0) {
> >> @@ -1050,7 +1052,7 @@ int netxen_get_flash_mac_addr(struct
> >> netxen_adapter *adapter, u64 *mac)
> >> =A0 =A0 =A0 if (netxen_get_flash_block(adapter, offset, sizeof(u64=
), pmac)
> =3D=3D
> >> -1)
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> >>
> >> - =A0 =A0 if (*mac =3D=3D cpu_to_le64(~0ULL)) {
> >> + =A0 =A0 if (*mac =3D=3D ~0ULL) {
> >
> > *mac is in little endian format so compare it with cpu_to_le64.
> >
> >>
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset =3D NX_OLD_MAC_ADDR_OFFSET +
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (adapter->portnum * si=
zeof(u64));
> >> @@ -1059,7 +1061,7 @@ int netxen_get_flash_mac_addr(struct
> >> netxen_adapter *adapter, u64 *mac)
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 offset, sizeof(u64), pmac) =3D=3D
> -1)
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> >>
> >> - =A0 =A0 =A0 =A0 =A0 =A0 if (*mac =3D=3D cpu_to_le64(~0ULL))
> >> + =A0 =A0 =A0 =A0 =A0 =A0 if (*mac =3D=3D ~0ULL)
> >
> > *mac here is in little endian format so compare it with cpu_to_le64=
=2E
> >
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> >> =A0 =A0 =A0 }
> >> =A0 =A0 =A0 return 0;
> >> @@ -2178,7 +2180,7 @@ lock_try:
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 NX_WR_DUMP_REG(FLASH_ROM_WINDOW, adapt=
er-
> >ahw.pci_base0,
> >> waddr);
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 raddr =3D FLASH_ROM_DATA + (fl_addr & =
0x0000FFFF);
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 NX_RD_DUMP_REG(raddr, adapter->ahw.pci=
_base0, &val);
> >> - =A0 =A0 =A0 =A0 =A0 =A0 *data_buff++ =3D cpu_to_le32(val);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 *data_buff++ =3D val;
> >
> > It should be cpu_to_le32 as it is returned to tool which requires
> > output in little endian.
> >
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 fl_addr +=3D sizeof(val);
> >> =A0 =A0 =A0 }
> >> =A0 =A0 =A0 readl((void __iomem *)(adapter->ahw.pci_base0 +
> >> NX_FLASH_SEM2_ULK));
> >> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> >> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> >> index 8dc4a134..70783b4 100644
> >> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> >> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> >> @@ -818,7 +818,7 @@ netxen_check_options(struct netxen_adapter
> >> *adapter)
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 adapter->driver_mismat=
ch =3D 1;
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> >> - =A0 =A0 =A0 =A0 =A0 =A0 ptr32[i] =3D cpu_to_le32(val);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 ptr32[i] =3D val;
> >
> > Here val should be in little endian (cpu_to_le32) as it will be
> referenced by byte array to print serial number.
> >
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset +=3D sizeof(u32);
> >> =A0 =A0 =A0 }
> >>
> >> --
> >> 1.7.4.4
> >>
> >
> >
> > Sorry for Late reply.
> >
> > Rajesh
> >
