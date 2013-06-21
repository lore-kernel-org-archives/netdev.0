From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 6/6] bonding: add an option to fail when any
 of arp_ip_target is inaccessible
Date: Fri, 21 Jun 2013 14:42:52 +0200
Message-ID: <20130621124252.GH1157@redhat.com>
References: <1371746105-2482-7-git-send-email-vfalico@redhat.com>
 <51C33BD7.4090508@redhat.com>
 <20130620181624.GA2756@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161196Ab3FUMnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 08:43:16 -0400
Content-Disposition: inline
In-Reply-To: <20130620181624.GA2756@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 08:16:24PM +0200, Veaceslav Falico wrote:
>On Thu, Jun 20, 2013 at 07:28:55PM +0200, Nikolay Aleksandrov wrote:
>>On 20/06/13 18:35, Veaceslav Falico wrote:
...snip...
>>>+		if (ind == 0 && targets[1] == 0 && bond->params.arp_validate) {
>>>+			pr_err("%s: can't remove last arp target if arp_validate is on\n",
>>>+				bond->dev->name);
>>>+			goto out;
>>>+		}
>>Can't I turn arp_validate off, then delete the last target and then turn
>>it on again ? Are you fixing the 0 first entry with this ?
>
>You can, it's a bug in bonding_store_arp_validate(), which also should be
>addressed, but I wouldn't like to address all the bugs in one patch, and
>this one is a great candidate for a standalone patch.
>

After some more feedback, thoughts and testing, I think I'll change it to
just pr_warning() - otherwise it might break existing scripts, if we fail.
