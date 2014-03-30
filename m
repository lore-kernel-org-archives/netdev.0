From: Alon Harel <alonhrl.us@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Sun, 30 Mar 2014 15:08:29 +0300
Message-ID: <CAMgxPs5gBJHDQ+4w_7r6LLR0_j4WEwhtLkdLYh+s6Xx0at08bg@mail.gmail.com>
References: <20140326173536.GJ2869@minipsycho.orion>
	<CAGVrzca84nbsyG3ETvn4nkgpMtYTh_dFDbzCywSdQ9uJjLVOUg@mail.gmail.com>
	<20140326181436.GL2869@minipsycho.orion>
	<53334BDA.1060608@mojatatu.com>
	<CAGVrzcaconDBjgSfk0=6px2+6LbrxMkmesgigSa3-9WaK-LiOw@mail.gmail.com>
	<20140327065616.GA2845@minipsycho.orion>
	<CAHNKnsQYLNfkrC0088g2os30NcSz9HVzkytbK_qFbNfeSWkmFw@mail.gmail.com>
	<CAGVrzcaWQH0aH3HOFdhaX2K3sGkfn4EitWaN+17R1oU4xtudWg@mail.gmail.com>
	<CAHNKnsTs6o3bFr241Cj_=muGMgOq3fc9ZNXcBRt3M8+ccTJscA@mail.gmail.com>
	<CAGVrzcY=hxAf0eOoDfAAQZS1fNjFWbdY9Nbyuz6kFaOkSSis8w@mail.gmail.com>
	<20140328062827.GB2805@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.c
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:35152 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbaC3NuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2014 09:50:25 -0400
Received: by mail-qc0-f182.google.com with SMTP id e16so7967299qcx.27
        for <netdev@vger.kernel.org>; Sun, 30 Mar 2014 06:50:24 -0700 (PDT)
In-Reply-To: <20140328062827.GB2805@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-28 9:28 GMT+03:00 Jiri Pirko <jiri@resnulli.us>:
>
> Thu, Mar 27, 2014 at 10:20:06PM CET, f.fainelli@gmail.com wrote:
> >2014-03-27 13:32 GMT-07:00 Sergey Ryazanov <ryazanov.s.a@gmail.com>:
> >> 2014-03-27 20:41 GMT+04:00 Florian Fainelli <f.fainelli@gmail.com>:
> >>> 2014-03-27 7:10 GMT-07:00 Sergey Ryazanov <ryazanov.s.a@gmail.com>:
> >>>> Hi all,
> >>>>
> >>>> sorry for the intrusion, but let me place my 2 cents.
> >>>>
> >>>> 2014-03-27 10:56 GMT+04:00 Jiri Pirko <jiri@resnulli.us>:
> >>>>> Wed, Mar 26, 2014 at 11:22:51PM CET, f.fainelli@gmail.com wrote:
> >>>>>>2014-03-26 14:51 GMT-07:00 Jamal Hadi Salim <jhs@mojatatu.com>:
> >>>>>>> On 03/26/14 14:14, Jiri Pirko wrote:
> >>>>>>>>
> >>>>>>>> Wed, Mar 26, 2014 at 06:58:32PM CET, f.fainelli@gmail.com wrote:
> >>>>>>>>>
> >>>>>>>>> 2014-03-26 10:35 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
> >>>>>>>
> >>>>>>>
> >>>>>>>
> >>>>>>>>> You are right, sw1p0 and sw1p1 were meant to be, say LAN ports in my
> >>>>>>>>> example.
> >>>>>>>>>
> >>>>>>>>> I think there is an implicit convention that sw1 represents the
> >>>>>>>>> Ethernet switch port connected to the CPU Ethernet MAC, and that it is
> >>>>>>>>> always connected, hence there is no need to create a "fake" bridge to
> >>>>>>>>> link sw1 to eth0 for instance?
> >>>>>>>>
> >>>>>>>>
> >>>>>>>> I think you are kind of mixing apples and oranges (or I might be I'm not
> >>>>>>>> understanding you correctly).
> >>>>>>>> This is how I see it, sticking to the names you use in the example:
> >>>>>>>>
> >>>>>>>>              (sw1) (abstract place-holder netdev)
> >>>>>>>>            --------
> >>>>>>>>           switch chip                   CPU
> >>>>>>>>     -----------------------            ------
> >>>>>>>>     sw1p0 sw1p1 sw1p2 sw1p3             eth0
> >>>>>>>>       |     |     |     |                |
> >>>>>>>>      PHY   PHY   PHY    ------someMII-----
> >>>>>>>>
> >>>>>>>> You see that eth0 is the CPU part of the "connection" and sw1p3 is the
> >>>>>>>> switch part (port representation).
> >>>>>>>>
> >>>>>>>
> >>>>>>>
> >>>>>>> Florian - I am sure you explained this before; I just dont remember. Why
> >>>>>>> is there need to expose eth0? It seems to me sw1p0-3 are abstracted
> >>>>>>> already in the kernel and the "cpu port" is merely a control interface.
> >>>>>>
> >>>>>>eth0 corresponds to a CPU Ethernet MAC facing e.g: sw1p3 switch port.
> >>>>>>It is "regular" Ethernet driver connected to the switch without
> >>>>>>switch-specific logic. The goal is twofold:
> >>>>>>
> >>>>>>- allow any regular Ethernet driver to be connected to an external
> >>>>>>switch via e.g: MDIO/MDC or other without specific switch knowledge
> >>>>>>- represents accurately how the hardware is designed/connected
> >>>>>>
> >>>>>>but maybe, we can simplify and have e.g: sw1p3 and eth0 be the same interface...
> >>>>>
> >>>>> I believe that hawing both sw1p3 and eth0 is the correct way of
> >>>>> modelling this. sw1p3 is instance if switch chip driver representing the
> >>>>> actual port of a switch. eth0 is an instance of some other ordinary NIC
> >>>>> driver (8139too is my favorite :))
> >>>>>
> >>>>> This model allows to draw the exact picture.
> >>>>> Also, when you add the described possibility to use iplink to build
> >>>>> vlans, bridges whatever on the switch ports, it makes perfect sense to
> >>>>> have this model.
> >>>>>
> >>>>> Merging sw1p3 and eth0 would cause a loose of information and confusion.
> >>>>>
> >>>>
> >>>> CPU switch port and switch fabric itself should be configured in
> >>>> consistence with host, in first place I mean a set of VLANs. Also it
> >>>> should be mentioned that some generic knobs such as port rate and
> >>>> duplex mode are meaningless for CPU switch port and a lot of status
> >>>> information (rx/tx counters etc.) duplicates statistics of host
> >>>> interface which is connected to switch port.
> >>>
> >>> It duplicates the information when things just work fine, consider an
> >>> external switch connected via RGMII to a CPU Ethernet MAC, you might
> >>> want to get statistics from both sides (the switch CPU port and the
> >>> CPU Ethernet MAC) to diagnose why things are not working as expected,
> >>> which unfortunately happens once in a while with RGMII.
> >>>
> >>> If we expose both net_device, we will be able to retrieve statistics
> >>> about from both sides, without resorting to ad-hoc debugging tools,
> >>> but maybe this is not worth the effort.
> >>>
> >> I also thought about this situation. Can we use the debugfs interface
> >> for these purposes?
> >
> >Most of the time you are interesting in MIB counters for debugging
> >such issues, so ethtool quickly comes handy for this task. Since we
> >will provide per-port counters, the CPU port is not different, so
> >there are no reason for restricting this.
>
> I agree, no need to provide parallel api.
>
> >
> >>
> >>>> So there are no reasons
> >>>> to force user to configure this port manually, and automatic
> >>>> configuration of CPU switch port without exporting them as netdev
> >>>> seems as good approach.
> >>>
> >>> Well, maybe that's the answer, since we know that e.g: sw1p3 is always
> >>> connected to e.g: eth0, we could create an automatic bridge between
> >>> those two, this would keep the netdev exposure to user-space, but an
> >>> user would not have to know about that specific detail to get things
> >>> to work.
> >>>
> >> I would like go further and suggest to consider a netdev that is
> >> connected to the CPU switch port, as master. In case when we need to
> >> perform some action on whole switch (e.g. dump FIB).
> >
> >This is what the 'sw1' net_device in Jiri's proposal would do.
>
> Except, sw1 is not cpu port. It's just a place holder not representing
> any physical port/netdev.
>
> >
> >> And even name
> >> switch ports, using master netdev name as prefix (e.g. eth1p0, eth1p1,
> >> ..., eth1pN for ports of switch that is connected via eth1).
> >
> >I think the port naming using the switch abstract interface (sw1 here)
> >is better because ports do belong to the switch.
> >--
> >Florian

Re sending (sorry, new to the mailing list and I don not have the
previous mails)

Sorry for jumping in a bit late.
I would like to comment on the point of coupling OVS datapath (dp) with one
piece of hardware. In the model I can think of, there is an embedded switch
in a NIC (eSwitch) with some virtual functions (VFs) through which some of
the VMs are connected (SRIOV) while at the same time there is also a
vSwitch (software switch), e.g. an OVS bridge instance through which other
VMs are connected using 'macvtap'. In this case, according to Jiri's path,
we will need more than one dp.
It looks like the support for multiple dp's was removed from OVS during its
evolution, Are we trying to add it back?
Another option would be to stay with a single dp and support crossing flow
(i.e. flows that cross switches) by additional logic that associates
ingress & egress port with a switch.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
