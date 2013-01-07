From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH v2 net-next 0/2] Remove NETIF_F_NETNS_LOCAL from software devices.
Date: Mon, 07 Jan 2013 01:25:25 -0800
Message-ID: <87d2xh5oqi.fsf@xmission.com>
References: <1357543176-15352-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37103 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796Ab3AGJZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 04:25:32 -0500
In-Reply-To: <1357543176-15352-1-git-send-email-ramirose@gmail.com> (Rami
	Rosen's message of "Mon, 7 Jan 2013 09:19:34 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rami Rosen <ramirose@gmail.com> writes:

> When NETIF_F_NETNS_LOCAL feature is set in some network device,  
> we do not allow this device to be moved from one network namespace 
> to another (see dev_change_net_namespace()). Vlan device is not considered 
> a local device and does not have the NETIF_F_NETNS_LOCAL feature. There is no 
> reason that software devices like ppp and bridge will set the
> NETIF_F_NETNS_LOCAL feature. This patchset removes NETIF_F_NETNS_LOCAL
> from ppp and bridge devices.

After you saw the case for vxlan I am disappointed you respun this
patchset without asking the question: Could other devices suffer
from the same class of problem.

It didn't take me more than a few minutes of looking to see that the
bridge and the ppp network device have the same class of issue as
vxlan.

> * Changes from v1
> 	Do not remove NETIF_F_NETNS_LOCAL from vxlan devices. Moving vxlan device 
> 	to a different namesapce does not move the state of the UDP socket related 
> 	to this vxlan device (Following Stephen Hemminger comment).
> 	
> Rami Rosen (2):
>   [RFC PATCH v2 net-next 1/3] ppp: remove NETIF_F_NETNS_LOCAL from ppp
>     device features.
>   [RFC PATCH v2 net-next 2/3] bridge: remove NETIF_F_NETNS_LOCAL from
>     bridge device features.
>
>  drivers/net/ppp/ppp_generic.c | 1 -
>  net/bridge/br_device.c        | 2 +-
>  2 files changed, 1 insertion(+), 2 deletions(-)
