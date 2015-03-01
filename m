From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Flows! Offload them.
Date: Sun, 1 Mar 2015 12:20:55 -0500
Message-ID: <20150301172055.GB32246@neilslaptop.think-freely.org>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226083758.GA15139@vergenet.net>
 <20150226091628.GA4059@nanopsycho.orion>
 <20150226133326.GC23050@casper.infradead.org>
 <54EF3A78.9020507@intel.com>
 <20150226201635.GA366@hmsreliant.think-freely.org>
 <20150226215255.GA15033@penelope.isobedori.kobe.vergenet.net>
 <20150227012239.GB8847@neilslaptop.think-freely.org>
 <20150227084141.GA17240@casper.infradead.org>
 <E4CD12F19ABA0C4D8729E087A761DC35067DC29B@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <simon.horman@netronome.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"jpettit@nicira.com" <jpettit@nicira.com>,
	"joestringer@nicira.com" <joestringer@nicira.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"shrijeet@gmail.com" <shrijeet@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"bcrl@kvack.org" <bcrl@
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44072 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbbCARVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 12:21:55 -0500
Content-Disposition: inline
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067DC29B@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 01, 2015 at 09:47:46AM +0000, Arad, Ronen wrote:
> 
> 
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> >Behalf Of Thomas Graf
> >Sent: Friday, February 27, 2015 12:42 AM
> >To: Neil Horman
> >Cc: Simon Horman; Fastabend, John R; Jiri Pirko; netdev@vger.kernel.org;
> >davem@davemloft.net; andy@greyhouse.net; dborkman@redhat.com;
> >ogerlitz@mellanox.com; jesse@nicira.com; jpettit@nicira.com;
> >joestringer@nicira.com; jhs@mojatatu.com; sfeldma@gmail.com;
> >f.fainelli@gmail.com; roopa@cumulusnetworks.com; linville@tuxdriver.com;
> >shrijeet@gmail.com; gospo@cumulusnetworks.com; bcrl@kvack.org
> >Subject: Re: Flows! Offload them.
> >
> >
> >Maybe I'm misunderstanding your statement here but I think it's essential
> >that the kernel is able to handle whatever we program in hardware even
> >if the hardware tables look differrent than the software tables, no matter
> >whether the configuration occurs through OVS or not. A punt to software
> >should always work even if it does not happen. So while I believe that
> >OVS needs more control over the hardware than available through the
> >datapath cache it must program both the hardware and software in parallel
> >even though the building blocks for doing so might look different.
> >
> 
> I believe that having an equivalent punt path should be optional and
> controlled by application policy. Some applications might give up on punt
> path due to its throughput implication and prefer to just drop in HW and 
> possibly leak some packets to software for exception processing and logging
> only. 
> 
Thats only one use case.  Having a software fallback path implemented by, and
gated by, application policy is fine for some newer application, but there is a
huge legacy set of applications available today, that relies on kernel
functionality for dataplane forwarding.  For this use case,  what we want/need
is the in-kernel dataplane to be opportunistically offloaded to whatever degree
possible, based on administratively assigned policy, and have that happen
transparently to user functionality.  The trade off there is that we don't
always have control over what exactly gets offloaded.

Thats why we need both API's.  Something like the flow API that can offer fine
grained control for applications that are new and willing to understand more
about the hardware they're using, and something at a kernel functional
granularity that provides legacy acceleration with all the tradeoffs that
entails.

Neil

> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
