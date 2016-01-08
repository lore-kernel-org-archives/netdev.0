From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net: pktgen: support injecting packets for qdisc testing
Date: Fri, 08 Jan 2016 13:55:13 -0800
Message-ID: <56903041.8090900@gmail.com>
References: <20160108020908.5940.89612.stgit@john-Precision-Tower-5810>	 <568FD5B7.2060602@gmail.com> <568FD7FC.8020005@gmail.com> <1452288964.8255.234.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34609 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbcAHVzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 16:55:25 -0500
Received: by mail-pf0-f172.google.com with SMTP id q63so15550251pfb.1
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 13:55:25 -0800 (PST)
In-Reply-To: <1452288964.8255.234.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-08 01:36 PM, Eric Dumazet wrote:
> On Fri, 2016-01-08 at 07:38 -0800, John Fastabend wrote:
> 
>> Also I'll respin this with a change so xmit_{drop|cn|policed} are not
>> counted as tx_bytes and pkts sent (idea from Jamal). However I won't
>> abort the burst because I do like this stressing the entry point of my
>> qdisc.
> 
> This reminds me that bonding/team drivers always return NETDEV_TX_OK
> status, even if the chosen slave could not queue or send the packet.
> 
> 
> 

hmm this could potentially break protocols that are handling the
return codes like fcoe which puts a packet back on its queue if it
can't be sent.

.John
