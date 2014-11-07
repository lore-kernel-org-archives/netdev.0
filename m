From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [linux-nics] [PATCH net 3/5] fm10k: Implement ndo_gso_check()
Date: Thu, 6 Nov 2014 16:55:30 -0800
Message-ID: <20141107003821.GA10692@gmail.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
 <1415138202-1197-4-git-send-email-joestringer@nicira.com>
 <1415190872.2420.55.camel@jtkirshe-mobl>
 <CAJ3xEMjaQ54yEUQGL-8VHoPm=4G5bhPaGBa55jypzfKviR4KyQ@mail.gmail.com>
 <1415191627.2420.61.camel@jtkirshe-mobl>
 <CANr6G5xBehKGVozOAM=m8CXY7Q8_kPu-s5zgwho4=npv=bQsrg@mail.gmail.com>
 <1415216204.2176.1.camel@jtkirshe-mobl.jf.intel.com>
 <D0814A3F.5EA53%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"shahed.shaikh" <shahed.shaikh@qlogic.com>,
	"sathya.perla" <sathya.perla@emulex.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Vadai <amirv@mellanox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	dept-gelinuxnicdev <Dept-GELinuxNICDev@qlogic.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"Amir@isotope.jf.intel.com" <Amir@isotope.jf.intel.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:60434 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750846AbaKGAzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 19:55:38 -0500
Received: by mail-pa0-f43.google.com with SMTP id eu11so2385448pac.2
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 16:55:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <D0814A3F.5EA53%matthew.vick@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 06, 2014 at 11:58:32PM +0000, Vick, Matthew wrote:
> On 11/5/14, 11:36 AM, "Jeff Kirsher" <jeffrey.t.kirsher@intel.com> wrote:
>
> >On Wed, 2014-11-05 at 10:26 -0800, Joe Stringer wrote:
> >> On 5 November 2014 04:47, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >>wrote:
> >> >
> >> > On Wed, 2014-11-05 at 14:44 +0200, Or Gerlitz wrote:
> >> > > On Wed, Nov 5, 2014 at 2:34 PM, Jeff Kirsher
> >> > > <jeffrey.t.kirsher@intel.com> wrote:
> >> > > > On Tue, 2014-11-04 at 13:56 -0800, Joe Stringer wrote:
> >> > > >> ndo_gso_check() was recently introduced to allow NICs to report
> >>the
> >> > > >> offloading support that they have on a per-skb basis. Add an
> >> > > >> implementation for this driver which checks for something that
> >>looks
> >> > > >> like VXLAN.
> >> > > >>
> >> > > >> Implementation shamelessly stolen from Tom Herbert:
> >> > > >> http://thread.gmane.org/gmane.linux.network/332428/focus=333111
> >> > > >>
> >> > > >> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> >> > > >> ---
> >> > > >> Should this driver report support for GSO on packets with tunnel
> >> > > >> headers
> >> > > >> up to 64B like the i40e driver does?
> >> > > >> ---
> >> > > >>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   12
> >>++++++++++++
> >> > > >>  1 file changed, 12 insertions(+)
> >> > > >
> >> > > > Thanks Joe, I will add your patch to my queue.
> >> > >
> >> > > Hi Jeff, please see my comment on patch 0/5, we're essentially
> >> > > replicating the same helper four different times (fm10k, mlx4,
> >>benet,
> >> > > qlgc) - I don't see the point in doing so. I asked Joe to come up
> >>with
> >> > > one generic helper and then to pick it up by the four drivers, makes
> >> > > sense?
> >> >
> >> > Yeah, I just saw your reply Or.  Ok, I will await an update to Joe's
> >> > series, thanks!
> >>
> >> Thanks Or/Jeff.
> >>
> >> There is also the question in the commit message above, perhaps fm10k
> >> support is a bit different - wasn't sure who to ask regarding that.
> >
> >Matthew Vick is the fm10k maintainer now and can answer any fm10k
> >questions you may have.
>
> Hi Joe, fm10k's hardware is pretty lax about the header size. As long as
> the total header length (outer+inner) is 184 bytes or less we're golden,
> so if I'm not mistaken that leaves us with a max of 130 bytes beyond the
> tunnel header.

Oh, okay. To be more explicit, in the case of UDP tunnels I take it that
you're talking about L2+L3+(L4+)tunnel+L2+L3+L4 <= 184? (L4 perhaps
optional depending on the tunnel protocol used)

In that case, the fm10k_gso_check would use something closer to
"skb_inner_transport_header(skb) - skb_mac_header(skb) > 184", or
perhaps 164 to allow for inner L4 header (?).

Joe
