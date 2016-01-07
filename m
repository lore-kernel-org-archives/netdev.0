From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next v2] net, sched: add clsact qdisc
Date: Thu, 07 Jan 2016 15:21:44 -0800
Message-ID: <568EF308.1060505@gmail.com>
References: <61198814638d88ce3555dbecf8ef875523b95743.1452197856.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, jhs@mojatatu.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34932 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbcAGXV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 18:21:58 -0500
Received: by mail-pf0-f182.google.com with SMTP id 65so414208pff.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 15:21:58 -0800 (PST)
In-Reply-To: <61198814638d88ce3555dbecf8ef875523b95743.1452197856.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-07 01:29 PM, Daniel Borkmann wrote:
> This work adds a generalization of the ingress qdisc as a qdisc holding
> only classifiers. The clsact qdisc works on ingress, but also on egress.
> In both cases, it's execution happens without taking the qdisc lock, and
> the main difference for the egress part compared to prior version of [1]
> is that this can be applied with _any_ underlying real egress qdisc (also
> classless ones).
> 

[...]

> Prior work on a mqprio prequeue() facility [1] was done mainly by John Fastabend.
> 
>   [1] http://patchwork.ozlabs.org/patch/512949/
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: John Fastabend <john.r.fastabend@intel.com>

Looks good to me and is a better implementation then my initial take
with the mqprio perqueue() stuff.

I think this complements the lockless work and also putting it in front
of the qdisc bypass logic lets us skip the qdisc but also still use
this for queue selection. Further we can build interesting queue
select logic now and maybe remove select_queue() from the ndo ops
eventually? With this and xps there really is no reason to have drivers
implementing some under-the-covers logic anymore.

Thanks,
John
