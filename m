From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: feature - ip link set <dev> primary <dev> ?
Date: Fri, 5 Feb 2016 10:10:18 +0100
Message-ID: <56B466FA.4000706@cumulusnetworks.com>
References: <56B41209.1060308@nurealm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: james@nurealm.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38137 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbcBEJKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 04:10:23 -0500
Received: by mail-wm0-f54.google.com with SMTP id p63so17623407wmp.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 01:10:22 -0800 (PST)
In-Reply-To: <56B41209.1060308@nurealm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/2016 04:07 AM, James Feeney wrote:
> Should there be an
> 
>  ip link set <primary-slave-device> primary <master-device>
> 
> command in the iproute2 package, to set the Primary Slave on a "bond" type link?
> 
> It seems that the alternative now is to use the sysfs, with
> 
>  echo -n <primary> > /sys/devices/virtual/net/<master-device>/bonding/primary
> 
> which, in systemd Service Unit Files, requires "/usr/bin/sh -c 'echo ...'"
> rather than simply "/usr/bin/echo ...".  "ip" seems to handle all other "bond"
> configuration itself.
> 
> Thanks
> James
> 

Hi James,
There is an iproute2 command that changes the primary,
$ ip link set dev <bond device> type bond primary <slave device>

Here's the output from the type bond help:
Usage: ... bond [ mode BONDMODE ] [ active_slave SLAVE_DEV ]
                [ clear_active_slave ] [ miimon MIIMON ]
                [ updelay UPDELAY ] [ downdelay DOWNDELAY ]
                [ use_carrier USE_CARRIER ]
                [ arp_interval ARP_INTERVAL ]
                [ arp_validate ARP_VALIDATE ]
                [ arp_all_targets ARP_ALL_TARGETS ]
                [ arp_ip_target [ ARP_IP_TARGET, ... ] ]
                [ primary SLAVE_DEV ]
                [ primary_reselect PRIMARY_RESELECT ]
                [ fail_over_mac FAIL_OVER_MAC ]
                [ xmit_hash_policy XMIT_HASH_POLICY ]
                [ resend_igmp RESEND_IGMP ]
                [ num_grat_arp|num_unsol_na NUM_GRAT_ARP|NUM_UNSOL_NA ]
                [ all_slaves_active ALL_SLAVES_ACTIVE ]
                [ min_links MIN_LINKS ]
                [ lp_interval LP_INTERVAL ]
                [ packets_per_slave PACKETS_PER_SLAVE ]
                [ lacp_rate LACP_RATE ]
                [ ad_select AD_SELECT ]

BONDMODE := balance-rr|active-backup|balance-xor|broadcast|802.3ad|balance-tlb|balance-alb
ARP_VALIDATE := none|active|backup|all
ARP_ALL_TARGETS := any|all
PRIMARY_RESELECT := always|better|failure
FAIL_OVER_MAC := none|active|follow
XMIT_HASH_POLICY := layer2|layer2+3|layer3+4
LACP_RATE := slow|fast
AD_SELECT := stable|bandwidth|count

Cheers,
 Nik
