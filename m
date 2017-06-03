From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [pull request][for-next 0/6] Mellanox mlx5 updates 2017-05-23
Date: Sun, 4 Jun 2017 01:45:41 +0300
Message-ID: <CALzJLG-uhtBM0nZw_r67q8Ji8pE9Vs=SCBCkcUErLMuwG7RtJA@mail.gmail.com>
References: <1496357879.7171.76.camel@redhat.com> <20170602153940.GX5406@mtr-leonro.local>
 <20170602160641.ylowbobe5v72ui7g@ast-mbp.dhcp.thefacebook.com>
 <20170602.120839.1394660754953676217.davem@davemloft.net> <20170602165736.nwunidodmu6xsmuv@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170602165736.nwunidodmu6xsmuv-+o4/htvd0TCa6kscz5V53/3mLCh9rsb+VpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 2, 2017 at 7:57 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Fri, Jun 02, 2017 at 12:08:39PM -0400, David Miller wrote:
>> From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Fri, 2 Jun 2017 09:06:43 -0700
>>
>> > On Fri, Jun 02, 2017 at 06:39:40PM +0300, Leon Romanovsky wrote:
>> >> On Thu, Jun 01, 2017 at 06:57:59PM -0400, Doug Ledford wrote:
>> >> > On Thu, 2017-05-25 at 12:02 -0400, David Miller wrote:
>> >> > > From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> >> > > Date: Tue, 23 May 2017 14:43:58 +0300
>> >> > >
>> >> > > > Hi Dave and Doug,
>> >> > > >
>> >> > > > This series introduces some small updates and FPGA support to t=
he
>> >> > > mlx5
>> >> > > > core/ethernet and IB drivers.
>> >> > > >
>> >> > > > For more details please see below.
>> >> > > >
>> >> > > > Please pull and let me know if there's any problem.
>> >> > >
>> >> > > Ok, I've pulled this into net-next.
>> >> > >
>> >> > > Doug let me know if there are any merge hassles we need to coordi=
nate
>> >> > > on.
>> >> > >
>> >> > > Thanks.
>> >> >
>> >> > Will do.  But is the question of a possible revert settled?  Becaus=
e
>> >> > once I pull, a revert means I have to pull all the way up to the re=
vert
>> >> > as well...
>> >>
>> >> Revert is unlikely to happen, Saeed is working with Alexey to resolve
>> >> his raised concerns.
>> >
>> > I still think the direction is absolutely wrong.
>> > Reinventing fpga interfaces via nic driver is no-go.
>> > mlx needs to send a patch to revert it to show that they are willing
>> > to listen to the community.
>>
>> "Two people from Facebook" is not the commnity Alexei. :-)
>
> I've read the thread that fpga folks are not excited about
> fpga behind the nic either... but yeah i'm mainly expressing
> my opinions here.
>
>> And ironically, you guys will want to be one of the main users of
>> these facilities for the KTLS offload bits, so the desire to separate
>> it out and make "backports easier" really confuses me.
>
> We will not be using ktls offload via hidden fpga which
> is not properly exposed to the kernel.
> We've learned our lesson with eswitch.
>

KTLS/IPSec or any mlx5 FPGA/Innova applications is yet to be submitted,
and as Ilan said the kernel API is WIP, and we will not push anything
until the kernel API is submitted and accepted.

The patch in question that you are asking to revert, is adding no new
fancy functionality or FPGA capabilities to the mlx5 driver yet.
it is only basic mlx5 core stuff to add support of new device
"Mellanox Innova=E2=84=A2 Flex 4 Lx EN Adapter Card" [1], so such device wh=
ich
is already in production
can work with the mlx5_core.ko as is (ConnectX4-Lx) with no special
offloads or special Innova applications.
so this patch is mandatory for those who have this device to have
basic and standard ConnectX4-Lx networking interfaces.

It also adds the needed code separation between mlx5 basic core and
Innova stuff for future Innova applications and API development
(IPsec,KTLS, etc ..), so it will be easy for you to remove Innova
support at compilation time. And when the time comes, each new part
will be introduced with the suitable kernel API in the right place.

> ktls patches are independent of hw offload. It's great that
> mlx fpga can accelerate ktls tx which is extra confirmation
> that ktls api is on the right track. There is still 'ktls rx'
> to finish and 'ktls rx offload' is even trickier, since it's
> more intrusive into the core networking. Once crypto scatter gather
> is improved, we expect to see 8% perf gain out of sw ktls alone.
> So ktls hw offload is complementary and not mandatory.
>
> Back to eswitch analogy. All I hear from mlx is "at this stage
> it's not approriate ...". Well, I've been asking to do
> 'the right thing' for eswitch for months now and eswitch was
> in the driver for years. What are the chances that this fpga
> will ever be exposed? Once the code is merged there is no
> incentive for the vendor to do it differently.
>

"mlx5 eswitch =3D=3D ethernet SRIOV" and today we already implement most
-if not all- of SRIOV VF ndos, and all are accessible from
"(ip link show) and (ip set vf xyz) " this is for the Legacy mode.
for the new switchdev mode, eswitch is managed by TC tool and
switchdev APIs only.

So we already have max kernel/user visibility in both modes.

can you clarify what bothers you and what is "the right thing"?
because i think we already agreed on the MLX5_ESWITCH/SRIOV kconfig
directive to eliminate eswitch for those who don't need it.
What exactly is missing ?

[1] http://www.mellanox.com/page/products_dyn?product_family=3D228&mtag=3Dp=
rogrammable_adapter_cards_
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
