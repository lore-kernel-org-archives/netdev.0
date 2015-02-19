From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next v5 5/6] bonding: Allow userspace to set actors' macaddr
 in an AD-system.
Date: Thu, 19 Feb 2015 01:15:44 +0100
Message-ID: <54E52B30.207@redhat.com>
References: <1424298688-18434-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbbBSAPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2015 19:15:55 -0500
In-Reply-To: <1424298688-18434-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2015 11:31 PM, Mahesh Bandewar wrote:
> In an AD system, the communication between actor and partner is the
> business between these two entities. In the current setup anyone on the
> same L2 can "guess" the LACPDU contents and then possibly send the
> spoofed LACPDUs and trick the partner causing connectivity issues for
> the AD system. This patch allows to use a random mac-address obscuring
> it's identity making it harder for someone in the L2 is do the same thing.
> 
> This patch allows user-space to choose the mac-address for the AD-system.
> This mac-address can not be NULL or a Multicast. If the mac-address is set
> from user-space; kernel will honor it and will not overwrite it. In the
> absence (value from user space); the logic will default to using the
> masters' mac as the mac-address for the AD-system.
> 
> It can be set using example code below -
> 
>    # modprobe bonding mode=4
>    # sys_mac_addr=$(printf '%02x:%02x:%02x:%02x:%02x:%02x' \
>                     $(( (RANDOM & 0xFE) | 0x02 )) \
>                     $(( RANDOM & 0xFF )) \
>                     $(( RANDOM & 0xFF )) \
>                     $(( RANDOM & 0xFF )) \
>                     $(( RANDOM & 0xFF )) \
>                     $(( RANDOM & 0xFF )))
>    # echo $sys_mac_addr > /sys/class/net/bond0/bonding/ad_actor_system
>    # echo +eth1 > /sys/class/net/bond0/bonding/slaves
>    ...
>    # ip link set bond0 up
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1:
>   Initial version
> v2:
>   Renamed ad_actor_system_mac_address to ad_actor_system
> v3:
>   Fixed commit message.
> v4:
>   Rebase
> v5:
>   Cosmetic changes
> 
>  Documentation/networking/bonding.txt | 12 ++++++++++++
>  drivers/net/bonding/bond_3ad.c       |  7 ++++++-
>  drivers/net/bonding/bond_main.c      |  1 +
>  drivers/net/bonding/bond_options.c   | 29 +++++++++++++++++++++++++++++
>  drivers/net/bonding/bond_procfs.c    |  6 ++++++
>  drivers/net/bonding/bond_sysfs.c     | 15 +++++++++++++++
>  include/net/bond_options.h           |  1 +
>  include/net/bonding.h                |  1 +
>  8 files changed, 71 insertions(+), 1 deletion(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
