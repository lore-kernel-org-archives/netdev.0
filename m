From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: [PATCH 1/1] ipv4: arp: Always update neighbour address when a
 gratuitous arp is received
Date: Fri, 20 Dec 2013 14:25:48 -0800
Message-ID: <CAO7SqHBn+S74R2smEVbSFPDhManXpOAczwzRg++q8BJHYMsLRw@mail.gmail.com>
References: <1387565962-9357-1-git-send-email-noureddine@aristanetworks.com>
	<20131220140617.09a672f7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:55652 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512Ab3LTWZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 17:25:49 -0500
Received: by mail-ve0-f178.google.com with SMTP id c14so1870672vea.9
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 14:25:48 -0800 (PST)
In-Reply-To: <20131220140617.09a672f7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I could make is_garp conditional on ARP_ACCEPT. Would that be a more
acceptable solution?
Otherwise, if some sort of rate limiting is needed we would have to
add an addr_updated field
to the neighbour structure that would save the time when the address
was updated and not just
any update to the neighbour.

Thanks,

Salam

On Fri, Dec 20, 2013 at 2:06 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 20 Dec 2013 10:59:22 -0800
> Salam Noureddine <noureddine@aristanetworks.com> wrote:
>
>> Gratuitous arp packets are useful in switchover scenarios to update
>> client arp tables as quickly as possible. Currently, the mac address
>> of a neighbour is only updated after a locktime period has elapsed
>> since the last update. In most use cases such delays are unacceptable
>> for network admins. Moreover, the "updated" field of the neighbour
>> stucture doesn't record the last time the address of a neighbour
>> changed but records any change that happens to the neighbour. This is
>> clearly a bug since locktime uses that field as meaning "addr_updated".
>> With this observation, I was able to perpetuate a stale address by
>> sending a stream of gratuitous arp packets spaced less than locktime
>> apart.
>>
>> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
>
> Doesn't this make the system more vulnerable to ARP spoofing?
