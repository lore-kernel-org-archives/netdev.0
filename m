From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bonding: fix send_peer_notif leekage on rtnl
 lock congestion
Date: Tue, 6 Aug 2013 14:17:01 +0200
Message-ID: <20130806121701.GQ22756@redhat.com>
References: <1375732053-829-1-git-send-email-vfalico@redhat.com>
 <20130805.161212.421332729798966037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048Ab3HFMRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 08:17:55 -0400
Content-Disposition: inline
In-Reply-To: <20130805.161212.421332729798966037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 04:12:12PM -0700, David Miller wrote:
>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Mon,  5 Aug 2013 21:47:33 +0200
>
>> @@ -2999,7 +3002,10 @@ void bond_activebackup_arp_mon(struct work_struct *work)
>>  		if (!rtnl_trylock()) {
>>  			read_lock(&bond->lock);
>>  			delta_in_ticks = 1;
>> -			should_notify_peers = false;
>> +			if (should_notify_peers) {
>> +				bond->send_peer_notif++;
>
>I doubt this increment to a shared datastructure is safe with
>the locks you hold here.
>
>You don't hold RTNL and you only have bond->lock as a reader.

You're right, we can race here. This whole locking juggling should be
changed.

Self-NAK for this, I'll rework it.
