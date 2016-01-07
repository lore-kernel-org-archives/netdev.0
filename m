From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net, sched: add clsact qdisc
Date: Thu, 7 Jan 2016 09:29:52 -0500
Message-ID: <568E7660.1070801@mojatatu.com>
References: <d091709bf1a93c65cdadc9a990c9065e065840b8.1452041153.git.daniel@iogearbox.net>
 <20160107035334.GA99020@ast-mbp.thefacebook.com>
 <568E395F.8020504@stressinduktion.org> <568E52E8.1010804@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, john.fastabend@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34455 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbcAGO37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 09:29:59 -0500
Received: by mail-io0-f169.google.com with SMTP id 1so206730299ion.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 06:29:58 -0800 (PST)
In-Reply-To: <568E52E8.1010804@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-07 06:58 AM, Daniel Borkmann wrote:
> On 01/07/2016 11:09 AM, Hannes Frederic Sowa wrote:

>
> Idea was that this is done before we pick txq as stated. F.e., could also
> be that we end up not having enqueue handler, thus moving this further down
> (not sure if there's a good place?), might make it all more scattered resp.
> complex to cover all parts.
>

 From a cursory glance (Will comment a lot more later, definetely bt 
netdev11 time):
I like the idea - actually i think that this is where John was heading
initially. Both efforts complement each other.
This scheme could be used to compensate for the queue lock avoidance
and do a direct txmit (and let the hardware do the scheduling).
The classid selection could clearly be done at this early stage.
And a few of the standard skb metadatum could be used to map to
hardware offloading.

cheers,
jamal
