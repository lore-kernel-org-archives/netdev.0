From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 6/6] bonding: add an option to fail when any
 of arp_ip_target is inaccessible
Date: Thu, 20 Jun 2013 00:29:38 +0200
Message-ID: <51C230D2.5070405@redhat.com>
References: <1371663286-12518-7-git-send-email-vfalico@redhat.com> <51C2299C.2040403@redhat.com> <20130619222459.GB10910@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58509 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935150Ab3FSWaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 18:30:30 -0400
In-Reply-To: <20130619222459.GB10910@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/06/13 00:24, Veaceslav Falico wrote:
> On Wed, Jun 19, 2013 at 11:58:52PM +0200, Nikolay Aleksandrov wrote:
>> On 19/06/13 19:34, Veaceslav Falico wrote:
<snip>
> Great catch! It gets even more interesting when we try to delete an IP
> target - cause we don't shift the slave's target_last_arp_rx. Will try to
> address that nicely.
> 
> And wrt the case of no arp IP targets - we shouldn't get there in the first
> place, actually, cause the whole slave_last_rx() depends on arp_validate,
> which depends on arp_interval and at least one arp_ip_target. However, I
> see that we can do that by removing them one by one via sysfs.
> 
> And, btw, we set the target_last_arp_rx in bond_enslave(), the same way as
> last_arp_rx :).
> 
Yes, but it is set only if there're targets already present that's why I
said after enslaving. In the case of later target addition
target_last_arp_rx[0] will be 0 and last_arp_rx will be set.

Cheers,
 Nik
> Awesome ideas, thank you!
> 
>>> +    }
>>>
>>>      return slave->dev->last_rx;
>>>  }
>>> @@ -486,6 +511,7 @@ extern const struct bond_parm_tbl bond_lacp_tbl[];
>>>  extern const struct bond_parm_tbl bond_mode_tbl[];
>>>  extern const struct bond_parm_tbl xmit_hashtype_tbl[];
>>>  extern const struct bond_parm_tbl arp_validate_tbl[];
>>> +extern const struct bond_parm_tbl arp_all_targets_tbl[];
>>>  extern const struct bond_parm_tbl fail_over_mac_tbl[];
>>>  extern const struct bond_parm_tbl pri_reselect_tbl[];
>>>  extern struct bond_parm_tbl ad_select_tbl[];
>>
