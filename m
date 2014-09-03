From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: SCTP research inquiry
Date: Wed, 03 Sep 2014 19:22:46 +0200
Message-ID: <54074E66.7000200@redhat.com>
References: <CAHJk9CcBb5VUs9vibXW1QBxPONcmitFSzA9KPZj46dW+6WLKdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Kostantinos Katsaros <dinos.katsaros@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756292AbaICRWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 13:22:50 -0400
In-Reply-To: <CAHJk9CcBb5VUs9vibXW1QBxPONcmitFSzA9KPZj46dW+6WLKdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2014 07:07 PM, Kostantinos Katsaros wrote:
> Dear NetDev list,
>
> I am a researcher from Univ. of Surrey. I know that this list is
> mainly for developers of linux-kernel but I want to ask for some help
> to understand the SCTP implementation and pointers to some aspects.
>
> What I would actually like to do, is to modify the default SCTP
> operation with respect to primary/secondary interface selection and
> analyse it in simulations with NS-3. However, I haven't found an API
> or some other help and I was advised to contact this list. I know that
> NS-3 is capable of using linux-kernel implementations through the use
> of DCE, but my issue here is in the SCTP implementation.
>
> There a few questions I have in a basic scenario with two nodes
> connected via 2 interfaces.
>
> - How can I dynamically select which of the two interfaces is primary?
> Which method is responsible or should be called to switch?

Have a look at the implementation of sctp_select_active_and_retran_path()
and sctp_assoc_choose_alter_transport() with sctp_assoc_update_retran_path().
Make sure you use a latest 3.17 rcX as it contains the latest changes to
it (which you will find with some more explanation in the git log under
net/sctp/).

> - I guess that SCTP has some variable holding the estimated RTT on
> each path (also used for calculating RTO). Is this accessible and how?
> I would like to use this as a triggering mechanism to the switch
> method above. In principle select the path with the minimum RTT.
>
> - In a similar way of TCP Westwood (Plus), I would like to estimate
> the available bandwidth and use this as trigger.
>
> - Finally, I want to monitor the ratio (packets or bytes sent) on each
> of the available paths. How can I implement such mechanism? Do I have
> to implement a 'sniffer'?
>
>
> I would appreciate any help, pointers, code snippets.
>
>
> Regards,
>
> Kostas
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
