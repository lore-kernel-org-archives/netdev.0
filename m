From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 net-next 6/6] bonding: add an option to fail when any
 of arp_ip_target is inaccessible
Date: Mon, 24 Jun 2013 11:26:52 +0200
Message-ID: <20130624092652.GN1157@redhat.com>
References: <1371820284-13280-7-git-send-email-vfalico@redhat.com>
 <9312.1371838880@death.nxdomain>
 <20130621192143.GB30542@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	linux@8192.net, nicolas.2p.debian@free.fr, rick.jones2@hp.com,
	nikolay@redhat.com, mkubecek@suse.cz
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198Ab3FXJ10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 05:27:26 -0400
Content-Disposition: inline
In-Reply-To: <20130621192143.GB30542@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 21, 2013 at 09:21:43PM +0200, Veaceslav Falico wrote:
>On Fri, Jun 21, 2013 at 11:21:20AM -0700, Jay Vosburgh wrote:
>>Veaceslav Falico <vfalico@redhat.com> wrote:
>...snip...
>>>--- a/Documentation/networking/bonding.txt
>>>+++ b/Documentation/networking/bonding.txt
>>>@@ -321,6 +321,23 @@ arp_validate
>>>
>>>	This option was added in bonding version 3.1.0.
>>>
>>>+arp_all_targets
>>>+
>>>+	Specifies whether, in active-backup mode with arp validation,
>>>+	any of the arp_ip_targets should be up to keep the slave up
>>>+	(default) or it should go down if at least one of
>>>+	arp_ip_targets doesn't reply to arp requests.
>>
>>	I would write the above as:
>>
>>	Specifies the quantity of arp_ip_targets that must be reachable
>>	in order for the ARP monitor to consider a slave as being up.
>>	This option affects only active-backup mode for slaves with
>>	arp_validation enabled.
>
>Yeah, a lot more clear. However, doesn't "the quantity" suggest some
>number, but not binary (as we have it)?
>
>Hrm, it's an interesting idea btw, to make it accept the exact quantity of
>reachable arp_ip_targets to be up, instead of any/all, though I don't think
>it'll find use in real world situation. It's easy to implement btw, we
>just need to get the n-th least fresh arp_ip_target in slave_last_rx(). And
>we can have -1 for all.
>
>If you think that it's viable - I can add it to the next version.

Anyway, I think that it's better to do with another patch, not to
complicate again this patchset.

...snip...
>>>+		if (ind == 0 && !targets[1] && bond->params.arp_validate)
>>>+			pr_warn("%s: removing last arp target with arp_validate on\n",
>>>+				bond->dev->name);
>>>+
>>
>>	There's no warning in the current code for removing the last
>>arp_ip_target; I don't think adding one is necessary, particularly if it
>>is just for the validate case.
>
>My logic was - if we're currently configured to be up by the arp_validate -
>and we removing the last arp_ip_target - then we're either in the process
>of shutting down the interface or something is really wrong. And, btw,
>there's such an pr_info() for bonding_store_arp_interval():
>
> 588                 if (!bond->params.arp_targets[0])
> 589                         pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
> 590                                 bond->dev->name);
>
>So, maybe, only change to bond->params.arp_interval instead of arp_validate?

I've changed it to arp_interval in the meanwhile for v4, it's a harmless
warning but can help a lot in the case of misconfiguration :).

Will send the v4 now.

>
>Thank you very much for the review!
>
>>
>>	-J
...snip...
