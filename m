From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 00/25] bonding: introduce new option API
Date: Wed, 22 Jan 2014 10:01:54 +0800
Message-ID: <52DF2692.9000909@huawei.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:54594 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbaAVCCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 21:02:22 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/21 22:54, Nikolay Aleksandrov wrote:
> Hi,
> This patchset's goal is to introduce a new option API which should be used
> to properly describe the bonding options with their mode dependcies and
> requirements. With this patchset applied we get centralized option
> manipulation, automatic RTNL acquire per option setting, automatic option
> range checking, mode dependcy checking and other various flags which are
> described in detail in patch 01's commit message and comments.
> Also the parameter passing is changed to use a specialized structure which
> is initialized to a value depending on the needs.
> The main exported functions are:
>  __bond_opt_set() - set an option (RTNL should be acquired prior)
>  bond_opt_init(val|str) - init a bond_opt_value struct for value or string
>                           parameter passing
>  bond_opt_tryset_rtnl() - function which tries to acquire rtnl, mainly used
>                           for sysfs
>  bond_opt_parse - used to parse or check for valid values
>  bond_opt_get - retrieve a pointer to bond_option struct for some option
>  bond_opt_get_val - retrieve a pointer to a bond_opt_value struct for
>                     some value
> 
> The same functions are used to set an option via sysfs and netlink, just
> the parameter that's passed is usually initialized in a different way.
> The converted options have multiple style fixes, there're some longer
> lines but they looked either ugly or were strings/pr_warnings, if you
> think some line would be better broken just let me know :-) there're
> also a few sscanf false-positive warnings.
> I decided to keep the "unsuppmodes" way of mode dep checking since it's
> straight forward, if we make a more general way for checking dependencies
> it'll be easy to change it.
> 
> Future plans for this work include:
>  - Automatic sysfs generation from the bond_opts[].
>  - Use of the API in bond_check_params() and thus cleaning it up (this has
>    actually started, I'll take care of the rest in a separate patch)
>  - Clean up all option-unrelated files of option definitions and functions
> 
> I've tried to leave as much documentation as possible, if there's anything
> unclear please let me know. One more thing, I haven't moved all
> option-related functions from bonding.h to the new bond_options.h, this
> will be done in a separate patch, it's in my todo list.
> 
> This patchset has been tested by setting each converted option via sysfs
> and netlink to a couple of wrong values, a couple of correct values and
> some random values, also for the opts that have flags they have been
> tested as well.
> 
> Best regards,
>  Nikolay Aleksandrov
> 

cool work, I think I can applied and test them, but it is really a hard work.:)

Ding

> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Veaceslav Falico <vfalico@redhat.com>
> CC: Scott Feldman <sfeldma@cumulusnetworks.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Nikolay Aleksandrov (25):
>   bonding: add infrastructure for an option API
>   bonding: convert mode setting to use the new option API
>   bonding: convert packets_per_slave to use the new option API
>   bonding: convert xmit_hash_policy to use the new option API
>   bonding: convert arp_validate to use the new option API
>   bonding: convert arp_all_targets to use the new option API
>   bonding: convert fail_over_mac to use the new option API
>   bonding: convert arp_interval to use the new option API
>   bonding: convert arp_ip_target to use the new option API
>   bonding: convert downdelay to use the new option API
>   bonding: convert updelay to use the new option API
>   bonding: convert lacp_rate to use the new option API
>   bonding: convert min_links to use the new option API
>   bonding: convert ad_select to use the new option API
>   bonding: convert num_peer_notif to use the new option API
>   bonding: convert miimon to use the new option API
>   bonding: convert primary to use the new option API
>   bonding: convert primary_reselect to use the new option API
>   bonding: convert use_carrier to use the new option API
>   bonding: convert active_slave to use the new option API
>   bonding: convert queue_id to use the new option API
>   bonding: convert all_slaves_active to use the new option API
>   bonding: convert resend_igmp to use the new option API
>   bonding: convert lp_interval to use the new option API
>   bonding: convert slaves to use the new option API
> 
>  drivers/net/bonding/bond_main.c    |  179 +++---
>  drivers/net/bonding/bond_netlink.c |   87 ++-
>  drivers/net/bonding/bond_options.c | 1086 +++++++++++++++++++++++++++---------
>  drivers/net/bonding/bond_options.h |  170 ++++++
>  drivers/net/bonding/bond_procfs.c  |   25 +-
>  drivers/net/bonding/bond_sysfs.c   |  519 +++--------------
>  drivers/net/bonding/bonding.h      |   29 +-
>  7 files changed, 1214 insertions(+), 881 deletions(-)
>  create mode 100644 drivers/net/bonding/bond_options.h
> 
