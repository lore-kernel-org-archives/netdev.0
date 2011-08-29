From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: Re: Unicast hash for IXGBEVF driver
Date: Mon, 29 Aug 2011 11:24:55 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019454265E@orsmsx508.amr.corp.intel.com>
References: <4E589B69.7020305@gmail.com>
	<CAL3LdT6UBxEgjEX0MMCRmnXw2243nq5GyvYtQ9JOdGRtnsHS6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>, J.Hwan Kim
	<frog1120@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAL3LdT6UBxEgjEX0MMCRmnXw2243nq5GyvYtQ9JOdGRtnsHS6g@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The ROPE bits should not be set for any of the VFs and only on the PF when it is in promiscuous mode.

The PFUTA bits are imperfect MAC address hash filters.  By setting them all to ones and then turning on the ROPE bit for each of the VFs you're essentially putting the VF into a sort of fake promiscuous mode.

This is not recommended.  Older drivers that did this had a bug in them.

- Greg

> -----Original Message-----
> From: tarbal@gmail.com [mailto:tarbal@gmail.com] On Behalf Of Jeff Kirsher
> Sent: Saturday, August 27, 2011 12:35 AM
> To: J.Hwan Kim; Rose, Gregory V
> Cc: netdev; e1000-devel@lists.sourceforge.net
> Subject: Re: Unicast hash for IXGBEVF driver
> 
> On Sat, Aug 27, 2011 at 00:23, J.Hwan Kim <frog1120@gmail.com> wrote:
> > Hi, everyone
> >
> > How can I distribute the packets according to destination MAC address
> > into multi-virtual fucntion queue?
> > Now, my setting is that all bit of PFUTA are '1' and ROPE bit is 1,
> > so all mac packet is duplicated to all VF queue.
> > I cannot understand the meaning of bits of PFUTA and the relation
> > with mac address.
> > I want to distribute the received packets to RX queues respectively,
> > not duplicated.
> >
> >
> > Thanks in advance.
> >
> > Best Regards,
> > J.Hwan Kim
> >
> 
> Adding Greg Rose, since he is the ixgbevf driver maintainer.  He
> should be able to answer your questions early next week, unless he is
> checking his email over the weekend.
> 
> --
> Cheers,
> Jeff
------------------------------------------------------------------------------
Special Offer -- Download ArcSight Logger for FREE!
Finally, a world-class log management solution at an even better 
price-free! And you'll get a free "Love Thy Logs" t-shirt when you
download Logger. Secure your free ArcSight Logger TODAY!
http://p.sf.net/sfu/arcsight-sdnews
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
