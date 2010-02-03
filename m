From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Wed, 3 Feb 2010 10:25:58 -0800
Message-ID: <20100203102558.75d7a919@nehalam>
References: <20100128223447.GC3109@del.dom.local>
	<4B621316.8070308@majjas.com>
	<20100128225621.GD3109@del.dom.local>
	<4B6216B9.1010802@majjas.com>
	<20100128153643.0fca3c51@nehalam>
	<4B645EF4.4050701@majjas.com>
	<20100131003449.GA11935@del.dom.local>
	<4B650D53.2010607@majjas.com>
	<4B65D0F9.2020602@majjas.com>
	<4B65FD12.7090101@majjas.com>
	<20100131221835.GA3317@del.dom.local>
	<20100201102018.7b597992@nehalam>
	<4B68F664.6050007@majjas.com>
	<4B69A897.7030408@majjas.com>
	<20100203085618.6662cc6f@nehalam>
	<4B69AD5C.5030601@majjas.com>
	<4B69BF05.6020802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Breuer <mbreuer@majjas.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35600 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754272Ab0BCS0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 13:26:51 -0500
In-Reply-To: <4B69BF05.6020802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 03 Feb 2010 10:23:01 -0800
"Justin P. Mattock" <justinmattock@gmail.com> wrote:

> On 02/03/10 09:07, Michael Breuer wrote:
> > On 02/03/2010 11:56 AM, Stephen Hemminger wrote:
> >> On Wed, 03 Feb 2010 11:47:19 -0500
> >> Michael Breuer<mbreuer@majjas.com> wrote:
> >>
> >>> Tracked this down. The status being returned is 0x3c0080 - good flow
> >>> control packets. Nothing is actually being dropped (confirmed by packet
> >>> trace on switch compared with packet trace on server).
> >>>
> >>> I whipped up a trivial patch to not count these as dropped packets and
> >>> will post to netdev.
> >>>
> >>> I'm not really sure what the driver should be doing in this case, but
> >>> resubmit seems to work.
> >> Looks like a flow control negotiation issue. You probably turned off
> >> flow control on the Linux side, but the switch is still doing flow
> >> control.
> >>
> > According to the driver:
> > Feb 3 12:03:02 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full
> > duplex, flow control both
> >
> > So if the rx flow control packet status is due to flow control being
> > disabled, then there's a different issue.
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at http://www.tux.org/lkml/
> >
> 
> 
> hmm.. after an hour or so I'm not seeing anything.
> from what I remember I turned the machine on in the
> hotel, then left the system there as I went out for a few hours
> (so maybe I need to wait).
> 
> Anyways I did keep dmesg of when this occurred, basically
> the log was spammed with these:
> 
> [  863.294057] sky2 eth0: rx error, status 0x580002 length 88
> [  865.646645] sky2 eth0: rx error, status 0x600002 length 96
> [ 1286.420471] sky2 eth0: rx error, status 0x600002 length 96
> [ 1286.499459] sky2 eth0: rx error, status 0x600002 length 96
> [ 1746.903826] sky2 eth0: rx error, status 0x600002 length 96
> [ 1754.263692] sky2 eth0: rx error, status 0x600002 length 96
> [ 1755.309360] sky2 eth0: rx error, status 0x680002 length 104
> [ 2213.256294] sky2 eth0: rx error, status 0x600002 length 96
> [ 2219.653342] sky2 eth0: rx error, status 0x580002 length 88
> [ 2221.673601] sky2 eth0: rx error, status 0x600002 length 96
> [ 2679.654655] sky2 eth0: rx error, status 0x680002 length 104
> [ 2692.315058] sky2 eth0: rx error, status 0x500002 length 80
> [ 2694.349612] sky2 eth0: rx error, status 0x580002 length 88
> [ 2703.676717] sky2 eth0: rx error, status 0x700002 length 112
> [ 2703.826375] sky2 eth0: rx error, status 0x600002 length 96
> [ 3187.504843] sky2 eth0: rx error, status 0x600002 length 96
> [ 3189.560744] sky2 eth0: rx error, status 0x600002 length 96
> [ 3672.475719] sky2 eth0: rx error, status 0x680002 length 104
> [ 3676.696959] sky2 eth0: rx error, status 0x680002 length 104
> 
> but while using the system with this, I didn't notice anything
> out of the ordinary.
> (if this fires off I can try a bisect for you guys, but right now
> since I'm not seeing anything, might be a different story);
> 

You were on a crappy hotel switch. Those are all CRC errors.



-- 
