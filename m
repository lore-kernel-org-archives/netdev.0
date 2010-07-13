From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Tue, 13 Jul 2010 10:50:52 +0200
Message-ID: <4C3C28EC.2000302@netfilter.org>
References: <20100713001115.GA3751@sortiz-mobl> <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <sameo@linux.intel.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Luciano Coelho <luciano.coelho@nokia.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54907 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167Ab0GMIwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jul 2010 04:52:00 -0400
In-Reply-To: <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/07/10 08:18, Changli Gao wrote:
> On Tue, Jul 13, 2010 at 8:11 AM, Samuel Ortiz <sameo@linux.intel.com> wrote:
>>
>> The userspace notification Xtables target sends a netlink notification
>> whenever a packet hits the target. Notifications have a label attribute
>> for userspace to match it against a previously set rule. The rules also
>> take a --all option to switch between sending a notification for all
>> packets or for the first one only.
>> Userspace can also send a netlink message to toggle this switch while the
>> target is in place. This target uses the nefilter netlink framework.
>>
>> This target combined with various matches (quota, rateest, etc..) allows
>> userspace to make decisions on interfaces handling. One could for example
>> decide to switch between power saving modes depending on estimated rate
>> thresholds.
>>
> 
> It much like the following iptables rules.
> 
> iptables -N log_and_drop
> iptables -A log_and_drop -j NFLOG --nflog-group 1 --nflog-prefix "log_and_drop"
> iptables -A log_and_drop -j DROP
> 
> ...
> iptables ... -m quota --quota-bytes 20000 -j log_and_drop
> ...

Indeed, this looks to me like something that you can do with NFLOG and
some combination of matches.
