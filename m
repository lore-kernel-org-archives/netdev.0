From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] pktgen: introduce 'rx' mode
Date: Thu, 30 Apr 2015 21:55:39 -0700
Message-ID: <5543074B.6020209@plumgrid.com>
References: <1430443127-14408-1-git-send-email-ast@plumgrid.com> <1430455610.3711.118.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:32876 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284AbbEAEzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 00:55:42 -0400
Received: by igbpi8 with SMTP id pi8so23412226igb.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 21:55:41 -0700 (PDT)
In-Reply-To: <1430455610.3711.118.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/30/15 9:46 PM, Eric Dumazet wrote:
> On Thu, 2015-04-30 at 18:18 -0700, Alexei Starovoitov wrote:
>
>> +		local_bh_disable();
>> +		atomic_add(burst, &skb->users);
>
> this atomic_add() could be done before local_bh_disable()

ok

>> +				break;
>
> after a break; you don't need the 'else', and therefore can save one
> tab/ indent level.

yes. good point.

>> +			} else {
>> +				/* skb was 'freed' by stack, so clean few
>> +				 * bits and reuse it
>> +				 */
>> +				skb->tc_verd = 0; /* reset reclass/redir ttl */
>
> tc_verd needs CONFIG_NET_CLS_ACT

great catch! thanks

> You could put the out: label here, and remove one local_bh_enable()
> before "goto out;"

sure. why not.

Thanks for the thorough review!
