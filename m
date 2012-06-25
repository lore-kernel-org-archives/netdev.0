From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH RFC 0/8] LLDP implementation for Linux
Date: Mon, 25 Jun 2012 12:00:05 -0700
Message-ID: <4FE8B535.70900@intel.com>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eldad Zack <eldad@fogrefinery.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28025 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753178Ab2FYTAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 15:00:06 -0400
In-Reply-To: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/25/2012 11:28 AM, Eldad Zack wrote:
> Hi all,
>
> This series of patches provides a partial LLDP (IEEE Std 802.1ab)
> implementation.
>
> I'd really appreciate a review of it.
>
> LLDP is a simple discovery protocol which advertises the identification and
> other info (such as MTU or capabilities) of device on the link. It can also
> help debug misconfigurations on the link layer (wrong MTU, wrong VLAN).
>

Why do you want to implement this in the kernel? We've been doing this
in user space for sometime without any issues and has some noted
advantages. Reduces kernel bloat, easier to add extend, etc.

Take a look at

http://www.open-lldp.org/open-lldp

What are we missing? Can we address any deficiencies here rather than
embedded this into the kernel.

> Some notes/questions:
>
> * Applies against net-next and mainline.
>
> * Included in this series is only LLDP output code.
>    This is not an issue since input and output are decoupled in LLDP anyway.
>    I'm working on the input code as well and will post it at some point in the
>    future.
>
> * Sysctl is used to do (some) configuration. This is done globally right now.
>    Before I add per-device sysctls: is it at all appropriate to use sysctl
>    here?

No, netlink is much nicer for these types of things. User space
can register for events and stay in sync and also all the other
relevant events are using netlink UP/DOWN/DORMANT events for
example.

>
> * By default, transmission is suppressed. To arm it, set
> 	/proc/sys/net/lldp/lldp_op_mode
>    to 1.
>
> * I've tested it on x86_64 and (qemu'd) x86.
>
> * I've tested it on my machine and it works with Ethernet and WLAN.
>
> * The last patch ("8021q/vlan: process NETDEV_GOING_DOWN") is needed
>    to be able to send shutdown PDU on VLAN interfaces, but has otherwise
>    no effect.
>

Do this in user space and you can handle all these events without
changing existing infrastructure.

> * Is there a better way to deal with 16-bit endianness other than masking and
>    shifting, when one field is more than a byte long (in this case 7/9)?
>
> * I usually only work on it on weekends, so I might be slow in responding back.

Please consider user space implementations (you don't have to use
mine) or let us know why we _need_ this in the kernel.

>
> Thanks in advance if you're taking the time to review it or test it!
>

I'll scan the patches shortly.

Thanks,
John
