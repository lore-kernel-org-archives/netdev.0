From: Daniel J Blueman <daniel@quora.org>
Subject: Re: [4.9.13] use after free in ipv4_mtu
Date: Tue, 7 Mar 2017 20:29:40 +0800
Message-ID: <CAMVG2st2i2EHP+Qqzj-o4Bchhy2ptNiQJUKPHXX=dmnV3JWpjQ@mail.gmail.com>
References: <CAMVG2ssDe2NMOZzeTF77H1zEEh3dBuT75bS6f81Tqd+3v_4J+g@mail.gmail.com>
 <1488460104.9415.325.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488461281.9415.327.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAMVG2styKvhUkVnhkFJ-B427sgnbxsBN8rJfE=wFd3wtXYXvrg@mail.gmail.com>
 <1488807904.9415.375.camel@edumazet-glaptop3.roam.corp.google.com> <1488817203.9415.382.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <shemminger@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:34484 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755076AbdCGMao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 07:30:44 -0500
Received: by mail-ua0-f193.google.com with SMTP id 72so55901uaf.1
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 04:29:46 -0800 (PST)
In-Reply-To: <1488817203.9415.382.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 March 2017 at 00:20, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-03-06 at 05:45 -0800, Eric Dumazet wrote:
>> On Mon, 2017-03-06 at 14:33 +0800, Daniel J Blueman wrote:
>
>> > I do change the network queueing discipline and related at runtime [1]
>> > which may be triggering this, though I did think I saw the KASAN
>> > report only after resuming from suspend. rf(un)kill and other tweaking
>> > may have been involved too.
>> >
>> > Thanks,
>> >   Dan
>> >
>> > [1] /etc/sysctl.d/90-tcp.conf
>> >
>> > net.core.default_qdisc = fq_codel
>> > net.ipv4.tcp_congestion_control = bbr
>> > net.ipv4.tcp_slow_start_after_idle = 0
>> > net.ipv4.tcp_ecn = 1
>
> BTW, fq_codel is not suitable for BBR.
>
> Only fq contains the needed pacing for BBR.

Good tip, thanks Eric!
-- 
Daniel J Blueman
