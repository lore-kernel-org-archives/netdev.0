From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: Flows! Offload them.
Date: Sun, 1 Mar 2015 09:36:43 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC35067DC283@ORSMSX101.amr.corp.intel.com>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226083758.GA15139@vergenet.net>
 <20150226091628.GA4059@nanopsycho.orion>
 <20150226133326.GC23050@casper.infradead.org> <54EF3A78.9020507@intel.com>
 <20150226201635.GA366@hmsreliant.think-freely.org>
 <20150226215255.GA15033@penelope.isobedori.kobe.vergenet.net>
 <20150227012239.GB8847@neilslaptop.think-freely.org>
 <20150227084141.GA17240@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Simon Horman <simon.horman@netronome.com>,
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
	"bcrl@kvack.org" <bcrl@kvack.org>
To: Thomas Graf <tgraf@suug.ch>, Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:13771 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363AbbCAJgp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 04:36:45 -0500
In-Reply-To: <20150227084141.GA17240@casper.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Thomas Graf
>Sent: Friday, February 27, 2015 12:42 AM
>To: Neil Horman
>Cc: Simon Horman; Fastabend, John R; Jiri Pirko; netdev@vger.kernel.org;
>davem@davemloft.net; andy@greyhouse.net; dborkman@redhat.com;
>ogerlitz@mellanox.com; jesse@nicira.com; jpettit@nicira.com;
>joestringer@nicira.com; jhs@mojatatu.com; sfeldma@gmail.com;
>f.fainelli@gmail.com; roopa@cumulusnetworks.com; linville@tuxdriver.com;
>shrijeet@gmail.com; gospo@cumulusnetworks.com; bcrl@kvack.org
>Subject: Re: Flows! Offload them.
>
>Blind random offload of some packets is better than nothing but knowing
>and having control over which packets are offloaded is essential. You
>typically don't want to randomly give one flow priority over another ;-)
>Some software CPUs might not be able to handle the load. I know what
>you mean though and as long as we allow to disable and overwrite this
>behaviour we are good.
>

Random offloading of flows does not preserve policy in general.
For example let's consider two flows A.B.C.0/24 and A.B.C.D with the more
specific rule has higher priority.
If only the first rule is offloaded to HW, packets matched by the second
rule will not be processed as expected by the user.
Deciding which flow could be offloaded is an optimization decision that
is better handled outside of the kernel. 
  
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
