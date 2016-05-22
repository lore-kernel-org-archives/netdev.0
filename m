From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Sun, 22 May 2016 12:35:07 -0400
Message-ID: <5741DFBB.8040003@mojatatu.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUj9u4bgG+7Tc06z0_wSRhAWCVSz5KsydrhcmpoJf39tg@mail.gmail.com>
 <1463712330.18194.261.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVGjibj_bU2k_27O_PmzG1tqc6wHhg03yUe2RGzR++owA@mail.gmail.com>
 <1463723432.18194.274.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35016 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbcEVQrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 12:47:43 -0400
Received: by mail-it0-f67.google.com with SMTP id z123so2770090itg.2
        for <netdev@vger.kernel.org>; Sun, 22 May 2016 09:47:42 -0700 (PDT)
In-Reply-To: <1463723432.18194.274.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-20 01:50 AM, Eric Dumazet wrote:

> It wont be inaccurate (no drift), as the writers hold the qdisc
> spinlock.
>
> It it the same with say IP/TCP SNMP counters :
>
> When an incoming frame is handled, it might change many SNMP counters,
> but an SNMP agent might fetch the whole set of SNMP values in the middle
> of the changes.
>
> IpInReceives
> IpInDelivers
> TcpInSegs
> IpExtInOctets
> IpExtInNoECTPkts
> ...
>
> The only 'problem' can be a off-by-one (or off-by-bytes-in-the-packet)
> transient error, that all SNMP agents are normally handling just fine.
>


I think qdisc stats being off by a bit are ok - hence the rcu
suggestion. I would have problems with action stats being off
(where they are used for billing).

cheers,
jamal
