From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [pull request][for-next 0/6] Mellanox mlx5 updates 2017-05-23
Date: Fri, 2 Jun 2017 09:57:38 -0700
Message-ID: <20170602165736.nwunidodmu6xsmuv@ast-mbp.dhcp.thefacebook.com>
References: <1496357879.7171.76.camel@redhat.com>
 <20170602153940.GX5406@mtr-leonro.local>
 <20170602160641.ylowbobe5v72ui7g@ast-mbp.dhcp.thefacebook.com>
 <20170602.120839.1394660754953676217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170602.120839.1394660754953676217.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2017 at 12:08:39PM -0400, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Fri, 2 Jun 2017 09:06:43 -0700
> 
> > On Fri, Jun 02, 2017 at 06:39:40PM +0300, Leon Romanovsky wrote:
> >> On Thu, Jun 01, 2017 at 06:57:59PM -0400, Doug Ledford wrote:
> >> > On Thu, 2017-05-25 at 12:02 -0400, David Miller wrote:
> >> > > From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >> > > Date: Tue, 23 May 2017 14:43:58 +0300
> >> > >
> >> > > > Hi Dave and Doug,
> >> > > > 
> >> > > > This series introduces some small updates and FPGA support to the
> >> > > mlx5
> >> > > > core/ethernet and IB drivers.
> >> > > > 
> >> > > > For more details please see below.
> >> > > > 
> >> > > > Please pull and let me know if there's any problem.
> >> > >
> >> > > Ok, I've pulled this into net-next.
> >> > >
> >> > > Doug let me know if there are any merge hassles we need to coordinate
> >> > > on.
> >> > >
> >> > > Thanks.
> >> >
> >> > Will do.  But is the question of a possible revert settled?  Because
> >> > once I pull, a revert means I have to pull all the way up to the revert
> >> > as well...
> >> 
> >> Revert is unlikely to happen, Saeed is working with Alexey to resolve
> >> his raised concerns.
> > 
> > I still think the direction is absolutely wrong.
> > Reinventing fpga interfaces via nic driver is no-go.
> > mlx needs to send a patch to revert it to show that they are willing
> > to listen to the community.
> 
> "Two people from Facebook" is not the commnity Alexei. :-)

I've read the thread that fpga folks are not excited about
fpga behind the nic either... but yeah i'm mainly expressing
my opinions here.

> And ironically, you guys will want to be one of the main users of
> these facilities for the KTLS offload bits, so the desire to separate
> it out and make "backports easier" really confuses me.

We will not be using ktls offload via hidden fpga which
is not properly exposed to the kernel.
We've learned our lesson with eswitch.

ktls patches are independent of hw offload. It's great that
mlx fpga can accelerate ktls tx which is extra confirmation
that ktls api is on the right track. There is still 'ktls rx'
to finish and 'ktls rx offload' is even trickier, since it's
more intrusive into the core networking. Once crypto scatter gather
is improved, we expect to see 8% perf gain out of sw ktls alone.
So ktls hw offload is complementary and not mandatory.

Back to eswitch analogy. All I hear from mlx is "at this stage
it's not approriate ...". Well, I've been asking to do
'the right thing' for eswitch for months now and eswitch was
in the driver for years. What are the chances that this fpga
will ever be exposed? Once the code is merged there is no
incentive for the vendor to do it differently.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
