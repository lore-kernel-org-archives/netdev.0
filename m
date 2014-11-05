From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v4] ipv6: mld: fix add_grhead skb_over_panic for devs
 with large MTUs
Date: Wed, 05 Nov 2014 23:46:05 +0100
Message-ID: <545AA8AD.2040807@redhat.com>
References: <1415215658-10054-1-git-send-email-dborkman@redhat.com> <CAHA+R7NKPvhut_K+xgtyJqd=a8Y=dfU80e8C7Jo1qgTdg=2ubg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, lw1a2.jing@gmail.com,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David L Stevens <david.stevens@oracle.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34086 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990AbaKEWqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 17:46:18 -0500
In-Reply-To: <CAHA+R7NKPvhut_K+xgtyJqd=a8Y=dfU80e8C7Jo1qgTdg=2ubg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 11:11 PM, Cong Wang wrote:
> On Wed, Nov 5, 2014 at 11:27 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> -static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
>> +static struct sk_buff *mld_newpack(struct inet6_dev *idev, unsigned int mtu)
>
> For net-next, you probably want to get rid of the 'mtu' parameter,
> since all callers use dev->mtu. :)

Yeah, feel free. ;) Probably for the longer term it might make sense to
look into ways to refactor and unify some of the more generic portions of
the IGMP/MLD code.
