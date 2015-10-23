From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH 0/2] limit xen vnic max queues number to online cpu
 number
Date: Fri, 23 Oct 2015 09:57:36 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD02F622669@AMSPEX01CL01.citrite.net>
References: <5629E796.5040203@oracle.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD02F6220AF@AMSPEX01CL01.citrite.net>
 <5629F851.6010309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Joe Jin <joe.jin@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:60624 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbbJWJ5j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:57:39 -0400
In-Reply-To: <5629F851.6010309@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Jin [mailto:joe.jin@oracle.com]
> Sent: 23 October 2015 10:05
> To: Paul Durrant; Wei Liu; Ian Campbell; Boris Ostrovsky; Konrad Rzeszutek
> Wilk; David S. Miller
> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org
> Subject: Re: [PATCH 0/2] limit xen vnic max queues number to online cpu
> number
> 
> On 10/23/2015 04:47 PM, Paul Durrant wrote:
> >> -----Original Message-----
> >> From: netdev-owner@vger.kernel.org [mailto:netdev-
> >> owner@vger.kernel.org] On Behalf Of Joe Jin
> >> Sent: 23 October 2015 08:54
> >> To: Wei Liu; Ian Campbell; Boris Ostrovsky; Konrad Rzeszutek Wilk; David
> S.
> >> Miller
> >> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org
> >> Subject: [PATCH 0/2] limit xen vnic max queues number to online cpu
> >> number
> >>
> >> Currently xen vnic allowed to create lots of queues by set module param
> >> max_queues(both netback and netfront), when queues number larger
> than
> >> cpu number, it does not help for performance but need more cpu time.
> >>
> >
> > But it's an override, so why would you want to limit it? The parameter
> should not be set in the common case.
> 
> Always we can not stop people use it because we provided it :)
> 

Indeed, and I believe it was provided largely for test purposes... to force the limit to whatever the admin wants.

> If queues number is larger than cpu number, with heavy network load,
> cpus have to take more time for interrupt, this lead others less
> chance to be scheduled.
> Imaging dom0 have 64 cpus, and assigned 4 vcpus to the guest, if
> set max_queues to 64 on guest, it will consumed more cpu times
> and bandwidth on backend, I think this is not we expected?
> 

I think that would be entirely expected.

  Paul

> Thanks,
> Joe
> >
> >   Paul
> >
> >> This patchset limit netback and netfront max queues number to online
> >> cpus number.
> >>
> >> Joe Jin (2):
> >>   xen-netback: limit xen vif max queues number to online cpus
> >>   xen-front: limit vnic max_queues number to online cpus
> >>
> >>  drivers/net/xen-netback/netback.c |   28 ++++++++++++++++++++++---
> ---
> >>  drivers/net/xen-netfront.c        |   27 +++++++++++++++++++++------
> >>  2 files changed, 43 insertions(+), 12 deletions(-)
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
