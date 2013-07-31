From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 1/5] bonding: convert to list API and replace
 bond's custom list
Date: Wed, 31 Jul 2013 20:49:10 +0200
Message-ID: <51F95C26.6090600@redhat.com>
References: <1375283553-32070-1-git-send-email-nikolay@redhat.com> <1375283553-32070-2-git-send-email-nikolay@redhat.com> <20130731113849.02746040@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	fubar@us.ibm.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54047 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760708Ab3GaStR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 14:49:17 -0400
In-Reply-To: <20130731113849.02746040@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2013 08:38 PM, Stephen Hemminger wrote:
> On Wed, 31 Jul 2013 17:12:29 +0200
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> -	bond_for_each_slave(bond, tmp, i)
>> +	list_for_each_entry(tmp, &bond->slave_list, list)
> 
> It would be nice to keep the wrapper macro's bond_for_each_slave
> and introduce a bond_for_each_slave_rcu() for the cases where you
> are using RCU.
> 
I had done it like that in the first versions of these patches but since
this patchset is changing parts that people have relied on for a long time
I'd prefer to keep the list_for_each_entry(_rcu) explicit at least in the
beginning so no one can get confused about what's happening or a person who
hasn't looked in the code recently would find it easier to get up to speed.
Also I don't think the full writing of list_for_each_entry has lead to
breaking any lines right now.
In the end I don't have strong feelings about how this should look, so
either way is fine with me, these are my arguments for doing it this way.

Nik
