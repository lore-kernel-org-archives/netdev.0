From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH next v5 4/6] bonding: Allow userspace to set actors' system_priority in AD system
Date: Thu, 19 Feb 2015 13:06:29 -0800
Message-ID: <9036.1424379989@famine>
References: <1424298685-18394-1-git-send-email-maheshb@google.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:41349 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbbBSVGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 16:06:37 -0500
In-reply-to: <1424298685-18394-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar <maheshb@google.com> wrote:

>This patch allows user to randomize the system-priority in an ad-system.
>The allowed range is 1 - 0xFFFF while default value is 0xFFFF. If user
>does not specify this value, the system defaults to 0xFFFF, which is
>what it was before this patch.
>
>Following example code could set the value -
>    # modprobe bonding mode=4
>    # sys_prio=$(( 1 + RANDOM + RANDOM ))
>    # echo $sys_prio > /sys/class/net/bond0/bonding/ad_actor_sys_prio
>    # echo +eth1 > /sys/class/net/bond0/bonding/slaves
>    ...
>    # ip link set bond0 up
>
>Signed-off-by: Mahesh Bandewar <maheshb@google.com>

	Mahesh: Andy and I got together at netdev01 and discussed the
patches of this series that add options to sysfs for bonding (patches 4,
5 and 6).  In summary, in my opinion a netlink / iproute2 interface
needs to be provided simultaneously with any new sysfs interface for
bonding.  I realize that the sysfs api to bonding won't go away, but
nevertheless users should be encouraged to use netlink preferentially.
Providing the api pieces together encourages this.

	As it happens, Andy mentioned that he has patches similar to
these three, but with the netlink portion already implemented.

	My suggestion here is therefore for Andy to post his patches,
and then we can merge these together, and get this implemented properly
with a minimum of duplicated effort.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
