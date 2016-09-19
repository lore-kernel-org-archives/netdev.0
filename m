From: Eric Leblond <eric@regit.org>
Subject: Re: eBPF: how to check the flow table
Date: Mon, 19 Sep 2016 08:56:55 +0200
Message-ID: <1474268215.32028.1.camel@regit.org>
References: <1474200135.19872.12.camel@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:49484 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751414AbcISG5A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 02:57:00 -0400
In-Reply-To: <1474200135.19872.12.camel@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sun, 2016-09-18 at 14:02 +0200, Eric Leblond wrote:
> Hello,
> 
> I'm currently testing a code implementing AF_PACKET bypass for
> Suricata. The idea is that Suricata is updating a hash table
> containing
> a list of flows it does not want to see anymore.
> 
> I want to check flow timeout from the userspace, so my current
> algorithm is doing:
> 
>     while (bpf_get_next_key(mapfd, &key, &next_key) == 0) {
>         bpf_lookup_elem(mapfd, &next_key, &value);
>         FlowCallback(mapfd, &next_key, &value, data);
>         key = next_key;
>     }
> 
> In the FlowCallback, I check the timing in the flow entry and I
> remove
> the key if the flow is timeout.
> 
> This is currently working well when there is only a few flows but on
> a
> real system with log of insertion in the table, the loop is never
> returning because we dequeue slower than we enqueue.
> 
> Is there a better algorithm or an other way to do it ? 

It seems I missed an obvious race condition in my existing code. I'll
continue to test and relive this thread if necessary.

BR,
-- 
Eric Leblond <eric@regit.org>
