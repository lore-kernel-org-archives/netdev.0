From: Erik Nordmark <nordmark@arista.com>
Subject: Re: [PATCH net-next v3] ipv6 addrconf: Implemented enhanced DAD
 (RFC7527)
Date: Fri, 2 Dec 2016 10:30:47 -0800
Message-ID: <5cc54cba-39d9-c136-9524-d09a5214b48e@arista.com>
References: <1480549159-8142-1-git-send-email-nordmark@arista.com>
 <20161202.122728.866530661223136346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        gilligan@arista.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34136 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753815AbcLBSao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:30:44 -0500
Received: by mail-pg0-f47.google.com with SMTP id x23so110076960pgx.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:30:44 -0800 (PST)
In-Reply-To: <20161202.122728.866530661223136346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/2/16 9:27 AM, David Miller wrote:
> From: Erik Nordmark <nordmark@arista.com>
> Date: Wed, 30 Nov 2016 15:39:19 -0800
>
>> @@ -794,6 +808,17 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>>   have_ifp:
>>   		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>>   			if (dad) {
>> +				if (nonce != 0 && ifp->dad_nonce == nonce) {
>> +					u8 *np = (u8 *)&nonce;
>> +					/* Matching nonce if looped back */
>> +					ND_PRINTK(2, notice,
>> +						  "%s: IPv6 DAD loopback for address %pI6c nonce %02x:%02x:%02x:%02x:%02x:%02x ignored\n",
>> +						  ifp->idev->dev->name,
>> +						  &ifp->addr,
>> +						  np[0], np[1], np[2], np[3],
>> +						  np[4], np[5]);
> I know you said you'd leave this, but I'd actually like to ask that you
> use %pM here to save some kernel size.
OK, I'll change that and resubmit.

Thanks,
    Erik

>
> Thank you.
