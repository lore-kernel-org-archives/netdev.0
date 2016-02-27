From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/5] vxlan: implement GPE in L2 mode
Date: Sat, 27 Feb 2016 20:31:42 +0100
Message-ID: <20160227203142.5b7309f3@griffin>
References: <cover.1456472746.git.jbenc@redhat.com>
	<6fe53252314d644e994950522d4320bc54ced928.1456472746.git.jbenc@redhat.com>
	<CALx6S34vm6nqce481mcH_S3sfc4B5ift7YwJmTba4Vvdvnmj3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbcB0Tbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2016 14:31:45 -0500
In-Reply-To: <CALx6S34vm6nqce481mcH_S3sfc4B5ift7YwJmTba4Vvdvnmj3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2016 15:51:29 -0800, Tom Herbert wrote:
> I don't think this is right. VXLAN-GPE is a separate protocol than
> VXLAN, they are not compatible on the wire and don't share flags or
> fields (for instance GPB uses bits in VXLAN that hold the next
> protocol in VXLAN-GPE). Neither is there a VXLAN_F_GPE flag defined in
> VXLAN to differentiate the two. So VXLAN-GPE would be used on a
> different port

Yes, and that's exactly what this patchset does. If there's the
VXLAN_F_GPE flag defined while creating the interface, the used UDP
port defaults to the VXLAN-GPE UDP port (but can be overriden) and the
driver expects that all packets received are VXLAN-GPE.

Note also that you can't define both GPE and GBP together, because as
you noted, they're not compatible. The driver correctly refuses such
combination.

> and probably needs its own rcv functions.

I don't see the need for code duplication. This patchset does exactly
what you described and reuses the code, as most of it is really the
same for all VXLAN modes. I also made sure this is as clean as possible
in the driver which was the reason for the previous 4 cleanup patchsets.

 Jiri
