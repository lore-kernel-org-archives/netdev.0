From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next v5 6/6] bonding: Implement user key part of port_key
 in an AD system.
Date: Thu, 19 Feb 2015 01:21:02 +0100
Message-ID: <54E52C6E.2010506@redhat.com>
References: <1424298689-18473-1-git-send-email-maheshb@google.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:32952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752360AbbBSAVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2015 19:21:14 -0500
In-Reply-To: <1424298689-18473-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2015 11:31 PM, Mahesh Bandewar wrote:
> The port key has three components - user-key, speed-part, and duplex-part.
> The LSBit is for the duplex-part, next 5 bits are for the speed while the
> remaining 10 bits are the user defined key bits. Get these 10 bits
> from the user-space (through the SysFs interface) and use it to form the
> admin port-key. Allowed range for the user-key is 0 - 1023 (10 bits). If
> it is not provided then use zero for the user-key-bits (default).
> 
> It can set using following example code -
> 
>    # modprobe bonding mode=4
>    # usr_port_key=$(( RANDOM & 0x3FF ))
>    # echo $usr_port_key > /sys/class/net/bond0/bonding/ad_user_port_key
>    # echo +eth1 > /sys/class/net/bond0/bonding/slaves
>    ...
>    # ip link set bond0 up
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1:
>   Initial version
> v2:
>   Renamed ad_actor_user_port_key ad_user_port_key
> v3-v4:
>   Rebase
> v5:
>   Cosmetic changes
> 
>  Documentation/networking/bonding.txt | 63 ++++++++++++++++++++++++++++++++++++
>  drivers/net/bonding/bond_3ad.c       | 14 ++++----
>  drivers/net/bonding/bond_main.c      | 10 ++++++
>  drivers/net/bonding/bond_options.c   | 26 +++++++++++++++
>  drivers/net/bonding/bond_sysfs.c     | 15 +++++++++
>  include/net/bond_options.h           |  1 +
>  include/net/bonding.h                |  1 +
>  7 files changed, 123 insertions(+), 7 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
