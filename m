From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: sit tunnel slow since added GSO/TSO support
Date: Sat, 14 Dec 2013 22:25:07 +0100
Message-ID: <52ACCCB3.7010401@redhat.com>
References: <52AB322B.7030802@redhat.com>	 <1386952124.19078.148.camel@edumazet-glaptop2.roam.corp.google.com> <1386975268.19078.190.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751554Ab3LNVZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Dec 2013 16:25:08 -0500
In-Reply-To: <1386975268.19078.190.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2013 11:54 PM, Eric Dumazet wrote:
> I tried the same setup than before and got good behavior on current
> net-next kernel
>
> modprobe sit
> ip link set sit0 up
> ip -6 addr add dev sit0 2002:af6:1153::/64
> ip -6 ro add 2002:a00::/24 via fe80:: dev sit0

Eric,
in my test I do not use sit0. I create a new tunnel interface:
ip tun add sittun mode sit remote $REMOTE_IPV4 local $LOCAL_IPV4 \
   dev $IFACE

Looking at "ip tun show" I see that sit0 has the nopmtudisc option by 
default, while sittun does not.

As I wrote in my original message, using nopmtudisc when creating my 
tunnel interface works around the problem.

So I think nopmtudisc is the key difference in our setups.

Regards,
Michal
