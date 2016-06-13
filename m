From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH v2 1/1] net sched actions: skbedit add support
 for mod-ing skb pkt_type
Date: Mon, 13 Jun 2016 10:00:27 +0200
Message-ID: <575E681B.8080500@iogearbox.net>
References: <1465766693-2336-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	Jamal Hadi Salim <hadi@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33872 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964919AbcFMIAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 04:00:31 -0400
In-Reply-To: <1465766693-2336-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

On 06/12/2016 11:24 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <hadi@mojatatu.com>
>
> Extremely useful for setting packet type to host so i dont
> have to modify the dst mac address using pedit (which requires
> that i know the mac address)
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

I'm wondering if this is a good idea, I was thinking about something
like this as well some time ago. So far pkt_type is just exposed as
read-only to user space right now and I'm a bit worried that when we
allow to set it arbitrarily, then this could lead to hard to debug
issues since skb->pkt_type is used in a lot of places with possibly
different assumptions and applications now need to mistrust the kernel
whether skb->pkt_type was actually what the kernel itself set in the
first place or skbedit with possibly some nonsense value (like rewriting
PACKET_OUTGOING into PACKET_LOOPBACK, etc). Did you audit that this
is safe?

Thanks,
Daniel
