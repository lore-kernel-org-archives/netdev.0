From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2] sctp: sctp_close: fix release of bindings
 for deferred call_rcu's
Date: Fri, 01 Feb 2013 15:33:48 +0100
Message-ID: <510BD24C.3050507@redhat.com>
References: <cover.1359726681.git.dborkman@redhat.com> <2e8cac1036ff146d5e4c609e9aecb3765f19b067.1359726681.git.dborkman@redhat.com> <510BCFB7.3050603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755328Ab3BAOdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 09:33:54 -0500
In-Reply-To: <510BCFB7.3050603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2013 03:22 PM, Vlad Yasevich wrote:
>> +
>> +    if (transport->asoc)
>> +        sctp_association_put(transport->asoc);
>> +
>> +    sctp_packet_free(&transport->packet);
>
> I think it might be better to do sctp_packet_free() before releasing transports ref on the association.  The reason is that if for some reason that ref is the last one, you'd trigger association_destroy()
> call and then come back to try to free the packet.  It just doesn't sound right.  It would be better to free the packet (which should be
> empty at this point anyway), and then drop the ref on the association.

Agreed, that's more sound.
