From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 1/4] rtnetlink: new flag NLM_F_HW_OFFLOAD to indicate
 kernel object offload to hardware
Date: Sat, 22 Nov 2014 12:29:36 +0000
Message-ID: <20141122122936.GD20810@casper.infradead.org>
References: <1416610170-21224-2-git-send-email-roopa@cumulusnetworks.com>
 <20141121231234.GA20810@casper.infradead.org>
 <546FD467.5030602@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	gospo@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34500 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbaKVM3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 07:29:40 -0500
Content-Disposition: inline
In-Reply-To: <546FD467.5030602@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/14 at 04:10pm, Roopa Prabhu wrote:
> On 11/21/14, 3:12 PM, Thomas Graf wrote:
> >On 11/21/14 at 02:49pm, roopa@cumulusnetworks.com wrote:
> >>diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
> >>index 1a85940..f78522d 100644
> >>--- a/include/uapi/linux/netlink.h
> >>+++ b/include/uapi/linux/netlink.h
> >>@@ -54,6 +54,8 @@ struct nlmsghdr {
> >>  #define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
> >>  #define NLM_F_ECHO		8	/* Echo this request 		*/
> >>  #define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
> >>++#define NLM_F_KERNEL       32      /* This msg is only for the kernel */
> >>+#define NLM_F_HW_OFFLOAD	64	/* offload this msg to hw */
> >>  /* Modifiers to GET request */
> >>  #define NLM_F_ROOT	0x100	/* specify tree	root	*/
> >The NLM_F_ flag space applies to all Netlink messages including non
> >networking bits and is reserved for flags vital to the functioning
> >of the Netlink protocol itself. I suggest you move this to a
> >RTNETLINK specific flags space.
> 
> I did try to add it at a layer lower than the netlink header. But, nothing
> else fits so well as this :).
> I did not find a place where i could make it a global flag for just
> networking objects. As I mention in my patch description,
> If not here it will be a per subsystem flag/attribute. I can post a patch
> showing that approach as well.

Global variables have their appeal ;-) The issue I see with this
besides polluting a wide namespace is that it is not extendable.
We get a single bit and if a single bit is not enough we'll start
adding things in lower layers anyway (as you already do).

I think this should really be an IFF_ flag for net_device so its
state is exposed to user space as well.
