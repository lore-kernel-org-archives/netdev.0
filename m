From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 09:58:32 -0700
Message-ID: <CAADnVQLxX4LGFfqd6x+krfEMB57y_o80xW_3brkPvEJueDNWVg@mail.gmail.com>
References: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
	<CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:55064 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbaI3Q6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 12:58:33 -0400
Received: by mail-qc0-f176.google.com with SMTP id r5so845468qcx.35
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 09:58:32 -0700 (PDT)
In-Reply-To: <CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 7:59 AM, Tom Herbert <therbert@google.com> wrote:
>
>> So, to summarize my questions -
>> 1. What should a driver set as the SKBs csum value when passing CHECKSUM_COMPLETE?
>
> This ones complete checksum of the Ethernet payload (start of IP
> header to the end of the packet).

I think it's confusing to describe CHECKSUM_COMPLETE this way.
It is such only because driver pulls eth header before passing skb to stack.
CHECKSUM_COMPLETE should cover the whole packet. If there are multiple
vlan headers in front of IP they should be part of csum, since not all
drivers may
have hw offloading for vlan. The most simplistic HW would compute csum over
the whole packet including eth header and driver will do
eth_type_trans+skb_postpull_rcsum
