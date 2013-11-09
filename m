From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Sat, 09 Nov 2013 08:43:51 -0500
Message-ID: <527E3C17.1080508@mojatatu.com>
References: <9333f540a9b87adbdd15e274d12a9d60994fdb34.1383850578.git.jbenc@redhat.com>	<20131108.150741.966018155704146843.davem@davemloft.net>	<20131109000434.GD28793@casper.infradead.org> <20131109.000012.1393414533296613338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, pablo@netfilter.org
To: David Miller <davem@davemloft.net>, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:59235 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab3KINnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 08:43:53 -0500
Received: by mail-pb0-f41.google.com with SMTP id wy17so3369486pbc.0
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 05:43:53 -0800 (PST)
In-Reply-To: <20131109.000012.1393414533296613338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/13 00:00, David Miller wrote:

> The user has the message, they gave it to us in the sendmsg()
> we are responding to.  We absolutely do not need to give it
> to them again.
>
> If they care about referring to the contents of that message, they can
> refer to it in their own copy and make sure they are really looking at
> the same thing by comparing the sequence number in the netlink ACK to
> the one they used in the netlink header they gave to the kernel in the
> sendmsg() call.
>
> What happens now is pure duplication, and for such huge netlink
> messages it's really not smart at all.
>

for errors, we need to give the user something back. This has been the
behavior for 80 years now. Giving them a HUGE message
back is rediculuos(tm). Ive had enough of SCTP doing that.
We need to cap it - sort of what ICMP does.
ICMP caps at 64B; something like 128B is reasonable.

cheers,
jamal
