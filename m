From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Thu, 25 May 2017 13:40:38 +0300
Message-ID: <CALzJLG-B_tAmASn_SMmPNiucq-tTpywHniRTkb4N32oGF6Y3Ng@mail.gmail.com>
References: <20170523114404.20387-1-saeedm@mellanox.com> <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp> <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jsorensen-b10kYP2dOMg@public.gmane.org" <jsorensen-b10kYP2dOMg@public.gmane.org>
To: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0-dp/nxUn679gfNUYDR5dMTsDSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 25, 2017 at 8:20 AM, Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>> -----Original Message-----
>> From: Alexei Starovoitov [mailto:alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org]
>>
>> On Tue, May 23, 2017 at 02:44:02PM +0300, Saeed Mahameed wrote:
>> > From: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> >
>> > Mellanox Innova is a NIC with ConnectX and an FPGA on the same
>> > board. The FPGA is a bump-on-the-wire and thus affects operation of
>> > the mlx5_core driver on the ConnectX ASIC.
>> >
>> > Add basic support for Innova in mlx5_core.
>> >
>> > This allows using the Innova card as a regular NIC, by detecting
>> > the FPGA capability bit, and verifying its load state before
>> > initializing ConnectX interfaces.
>>
>> That doesn't sound like cx4/cx5 hw that mlx5 driver suppose to support.
>
> Hi Alexei,
> Thanks for your feedback.
> Let me address your concerns.
>
> I didn't state it, but the current iterations of Innova cards include the
> ConnectX-4LX chip, which is exactly what mlx5 driver supports.
>
> The PCI interface is *only* through the ConnectX chip with some new
> Firmware commands. This patch doesn't register any new PCI device,
> so it does not make sense to create a separate driver.
>
>>
>> > Also detect FPGA fatal runtime failures and enter error state if
>> > they ever happen.
>> >
>> > All new FPGA-related logic is placed in its own subdirectory 'fpga',
>> > which may be built by selecting CONFIG_MLX5_FPGA.
>> > This prepares for further support of various Innova features in later
>> > patchsets.
>> > Additional details about hardware architecture will be provided as
>> > more features get submitted.
>> >
>> > Signed-off-by: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> > Reviewed-by: Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> > Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> > ---
>> >  MAINTAINERS                                        |  10 +
>> >  drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |  10 +
>> >  drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   3 +
>> >  drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  11 ++
>> >  drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c |  64 +++++++
>> >  drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h |  59 ++++++
>> >  .../net/ethernet/mellanox/mlx5/core/fpga/core.c    | 202
>> +++++++++++++++++++++
>> >  .../net/ethernet/mellanox/mlx5/core/fpga/core.h    |  99 ++++++++++
>> >  drivers/net/ethernet/mellanox/mlx5/core/main.c     |  19 +-
>> >  include/linux/mlx5/device.h                        |   6 +
>> >  include/linux/mlx5/driver.h                        |   5 +
>> >  include/linux/mlx5/mlx5_ifc.h                      |  11 +-
>> >  include/linux/mlx5/mlx5_ifc_fpga.h                 | 144
>> +++++++++++++++
>> >  13 files changed, 640 insertions(+), 3 deletions(-)
>>
>> Can you put it into different driver? Dumping everything into by far
>> the biggest nic driver already is already huge headache in terms on
>> maintainability, debugging and back ports.
>> Look at how intel splits their drivers.
>> ixgb, ixgbe, ixgbevf are different drivers thought they have a lot in
>> common. On one side it's a bit of copy paste, but on the other side

I don't think the ixgb example is the same, simply  ixgb, ixgbe,
ixgbevf have different PCI IDs
and even different SW/FW interfaces. On the other hand, same mlx5
driver can support all of
ConnetX4/5/6 device IDs with the same code flows, same interfaces.

>> it makes drivers much easier to develop and maintain independently.
>> ConnectX-6 code and any future hw support doesn't belong to
>> mlx5 driver at all.

Sorry i must disagree with you on this for the same reasons Ilan mentioned.
We can perfectly achieve the same with modular driver design all under the
same .ko module, with some kconfig flags to reduce the amount of code/features
this .ko provides.

>
> If you build your driver without explicitly enabling CONFIG_MLX5_FPGA=y
> (default is N) then you get none of this, and your driver is practically
> the same as before.
>
> The FPGA and CX operation is very tightly integrated.
> If you don't want any of this, simply don't opt-in to CONFIG_MLX5_FPGA.
>
> If you do want this, then splitting some of the logic to a
> separate kernel object will not gain anything useful (logic would stay
> the same), and just pollute the exported symbol table and open up the door
> for issues of inter-module compatibility and so on.
>
> Furthermore, the next patchset will introduce IPSec offload capabilities
> Which are declared in netdev->hw_features. Those cannot be modified
> after the netdevice is created, so all the extra logic has to be
> integrated into the mlx5 ethernet driver. This is another reason why
> a separate driver is a bad idea.
>
> We will include details about the board and how things work in the
> cover letter of the IPSec offload patchset.
>
> Ilan.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
