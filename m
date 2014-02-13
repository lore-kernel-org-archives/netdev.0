From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: clear iflink when moving to a new netns
Date: Wed, 12 Feb 2014 18:00:47 -0800
Message-ID: <87sirn4vqo.fsf@xmission.com>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
	<52FB969A.607@6wind.com>
	<CAHA+R7Pd07-3-ikK9=o=6ZhwT1PY6iZTmLUnCCsJ2-e=KS5jOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39661 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbaBMCAz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 21:00:55 -0500
In-Reply-To: <CAHA+R7Pd07-3-ikK9=o=6ZhwT1PY6iZTmLUnCCsJ2-e=KS5jOA@mail.gmail.com>
	(Cong Wang's message of "Wed, 12 Feb 2014 17:18:08 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> writes:

> On Wed, Feb 12, 2014 at 7:43 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> Le 12/02/2014 00:51, Cong Wang a =C3=A9crit :
>>
>>> From: Cong Wang <cwang@twopensource.com>
>>>
>>> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=3D66691
>>>
>>> macvlan and vlan both use iflink to identify its lower device,
>>> however, after such device is moved to the new netns, its iflink
>>> would become meaningless as ifindex is per netns. So, instead of
>>> forbid them moving to another netns, just clear this field so that
>>> it will not be dumped at least.
>>>
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Cc: Eric W. Biederman <ebiederm@xmission.com>
>>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> Signed-off-by: Cong Wang <cwang@twopensource.com>
>>
>> I wonder if this patch breaks things in ip tunnels.
>> For example, ip6_tunnel uses iflink to find tunnels that are bound t=
o an
>> interface.
>> If you reset this field, ipip6_tunnel_lookup() will fail when the tu=
nnel
>> moves
>> to another netns.
>
> Most tunnels set NETIF_F_NETNS_LOCAL, ip6_tunnel should set it too
> (need a patch). So this is not a problem.

There was an effort not long ago to make tunnels safe to pass between
namespaces.  NETIF_F_NETNS_LOCAL was removed from ip6_tunnel in that
effort.  Apparently something was overlooked.

Making iflink a netdevice reference or finding a way to remove it
entirely seems better that masking the problem.

Eric
