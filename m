From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: clear iflink when moving to a new netns
Date: Wed, 12 Feb 2014 17:18:08 -0800
Message-ID: <CAHA+R7Pd07-3-ikK9=o=6ZhwT1PY6iZTmLUnCCsJ2-e=KS5jOA@mail.gmail.com>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
	<52FB969A.607@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:52087 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbaBMBSK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 20:18:10 -0500
Received: by mail-lb0-f171.google.com with SMTP id c11so7649797lbj.2
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 17:18:09 -0800 (PST)
In-Reply-To: <52FB969A.607@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 7:43 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 12/02/2014 00:51, Cong Wang a =E9crit :
>
>> From: Cong Wang <cwang@twopensource.com>
>>
>> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=3D66691
>>
>> macvlan and vlan both use iflink to identify its lower device,
>> however, after such device is moved to the new netns, its iflink
>> would become meaningless as ifindex is per netns. So, instead of
>> forbid them moving to another netns, just clear this field so that
>> it will not be dumped at least.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Eric W. Biederman <ebiederm@xmission.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> Signed-off-by: Cong Wang <cwang@twopensource.com>
>
> I wonder if this patch breaks things in ip tunnels.
> For example, ip6_tunnel uses iflink to find tunnels that are bound to=
 an
> interface.
> If you reset this field, ipip6_tunnel_lookup() will fail when the tun=
nel
> moves
> to another netns.

Most tunnels set NETIF_F_NETNS_LOCAL, ip6_tunnel should set it too
(need a patch). So this is not a problem.
