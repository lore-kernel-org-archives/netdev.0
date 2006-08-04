From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Fri, 04 Aug 2006 04:23:51 -0700 (PDT)
Message-ID: <20060804.042351.104054029.davem@davemloft.net>
References: <1154695575.8425.16.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57009
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932489AbWHDLXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:23:46 -0400
To: yjwei@nanjing-fnst.com
In-Reply-To: <1154695575.8425.16.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@nanjing-fnst.com>
Date: Fri, 04 Aug 2006 08:46:13 -0400

> This always correct except when do active open in tcp client, which will
> send a SYN, that segment will not be counted, even if it is not
> restrained. Maybe I can do following to fix this:
> 
> int tcp_connect(struct sock *sk)
> ...
> +	tp->snd_nxt = tp->write_seq;
> 	TCP_SKB_CB(buff)->seq = tp->write_seq++;
> 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
> -	tp->snd_nxt = tp->write_seq;
> -	tp->pushed_seq = tp->write_seq;
> 
> 	tcp_transmit_skb(sk, buff, 1, GFP_KERNEL);
> +	tp->snd_nxt = tp->write_seq;
> +	tp->pushed_seq = tp->write_seq;
> 	TCP_INC_STATS(TCP_MIB_ACTIVEOPENS);
> 
> Do you agree with me? If It is correctly, I will send this patch soon.

This looks fine and should work.

Please add some comments in tcp_connect() explaining the ordering of
assignments, so that a future developer does not break things by
accident.

Thank you.
