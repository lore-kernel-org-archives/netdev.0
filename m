From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx
 queue based on rx queue.
Date: Mon, 11 Sep 2017 23:27:13 -0700
Message-ID: <b2ea01b3-b984-d59f-cbaf-b2fe6b5d9eea@intel.com>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
 <CALx6S35sM1CDrFuNE+L59Op_wKTRpATLAdRJafihr0mB9+vQ8g@mail.gmail.com>
 <1505188437.15310.137.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:32432 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750911AbdILG1P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 02:27:15 -0400
In-Reply-To: <1505188437.15310.137.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/11/2017 8:53 PM, Eric Dumazet wrote:
> On Mon, 2017-09-11 at 20:12 -0700, Tom Herbert wrote:
>
>> Two ints in sock_common for this purpose is quite expensive and the
>> use case for this is limited-- even if a RX->TX queue mapping were
>> introduced to eliminate the queue pair assumption this still won't
>> help if the receive and transmit interfaces are different for the
>> connection. I think we really need to see some very compelling results
>> to be able to justify this.
Will try to collect and post some perf data with symmetric queue 
configuration.

> Yes, this is unreasonable cost.
>
> XPS should really cover the case already.
>   
Eric,

Can you clarify how XPS covers the RX-> TX queue mapping case?
Is it possible to configure XPS to select TX queue based on the RX queue 
of a flow?
IIUC, it is based on the CPU of the thread doing the transmit OR based 
on skb->priority to TC mapping?
It may be possible to get this effect if the the threads are pinned to a 
core, but if the app threads are
freely moving, i am not sure how XPS can be configured to select the TX 
queue based on the RX queue of a flow.

Thanks
Sridhar
