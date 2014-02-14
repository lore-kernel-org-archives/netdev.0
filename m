From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] packet: check for ndo_select_queue during queue selection
Date: Fri, 14 Feb 2014 11:21:22 +0100
Message-ID: <52FDEE22.9010503@redhat.com>
References: <1392311935-10275-1-git-send-email-dborkman@redhat.com> <20140214.004048.616136663605863975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mathias.kretschmer@fokus.fraunhofer.de, netdev@vger.kernel.org,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972AbaBNKVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 05:21:30 -0500
In-Reply-To: <20140214.004048.616136663605863975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2014 06:40 AM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu, 13 Feb 2014 18:18:55 +0100
>
>> The original pktgen scenario for which PACKET_QDISC_BYPASS was
>> designed for is still intact with this change anyway. We think
>
> I guess you have no intention of using this feature on bnx2x, ixgbe,
> or mlx4 devices then?  That covers a rather large component of gigabit
> ethernet devices out there, doesn't it?
>
> They both hook up an ndo_select_queue method.

Yes, it's suboptimal :/ The other two possibilities I see is 1) to check
for dev->ieee80211_ptr on setsockopt(2) and bind(2) (which could happen
_after_ the option was set) and just disallow that option for those cases
(doesn't make sense to use it for ieee80211 devs anyway, and they seem to
be the only special-cased users), or, preferably 2) to just leave the
code as it currently is, that is, similar to pktgen.
