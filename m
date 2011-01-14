From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 0/2] net: add device groups
Date: Fri, 14 Jan 2011 08:08:10 -0800
Message-ID: <20110114080810.2f128064@nehalam>
References: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51340 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757884Ab1ANQIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 11:08:13 -0500
In-Reply-To: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Jan 2011 11:38:29 +0200
Vlad Dogaru <ddvlad@rosedu.org> wrote:

> This patchset implements network device grouping and simple manipulation
> of groups. Netlink has been updated to provide group information and
> means of applying changes to members of a specific group via a single
> message.
> 
> The patchset has a corresponding one for iproute2, which implements the
> new functionality in userspace.
> 
> Some basic testing, using 1024 dummy network interfaces (all of them in
> group 0):
> 
> # time { for i in `seq 0 1023`; do ip l s dev dummy$i up; done }
> 
> real	0m7.70s
> user	0m0.36s
> sys	0m4.85s
> 
> # time ip l s devgroup 0 up
> 
> real	0m0.14s
> user	0m0.00s
> sys	0m0.14s
> 
> # time { for i in `seq 0 1023`; do ip l s dev dummy$i mtu 2000; done }
> 
> real	0m7.43s
> user	0m0.48s
> sys	0m4.72s
> 
> # time ip l s devgroup 0 mtu 2000
> 
> real	0m0.02s
> user	0m0.00s
> sys	0m0.02s
> 
> Improvement stems both from less user-kernel communication and from less
> processes being created.
> 
> Changes since version 2:
>  * fix net_device field type (should be int, not unsigned int).
>  * fix typo in commit message.
> 
> Changes since version 1:
>  * we avoid adding a new attribute type by using the following
>    convention: if no device name is specified, the interface index is
>    negative, and there is a group specified, we change parameters for
>    the whole group.
>  * the dummy module is no longer modified to include an initial group
>    for the devices it creates. The user is responsible for moving them
>    to a different group by means of the provided netlink interface.
> 
> Vlad Dogaru (2):
>   net_device: add support for network device groups
>   netlink: support setting devgroup parameters
> 
>  include/linux/if_link.h   |    1 +
>  include/linux/netdevice.h |    7 +++++++
>  net/core/dev.c            |   12 ++++++++++++
>  net/core/rtnetlink.c      |   38 ++++++++++++++++++++++++++++++++++----
>  4 files changed, 54 insertions(+), 4 deletions(-)

What about a read/write sysfs interface as well?
  /sys/class/net/eth0/devgroup

Not sure if numeric devgroup is best choice. Since this is more of
a human interface parameter maybe it should be a string? Or have
a translation in the utilities /etc/iproute2/devgroup?



-- 
