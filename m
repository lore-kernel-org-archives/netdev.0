From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH] net/dccp: fix use after free in tw_timer_handler()
Date: Wed, 22 Feb 2017 11:59:03 +0300
Message-ID: <6b21534b-060d-9eac-53f1-7fb3ec448358@virtuozzo.com>
References: <CACT4Y+aZrpZ3JevLrg5i=nTzBAcVhKX9qmajyW5b-+xExwrCHg@mail.gmail.com>
 <20170221112740.661-1-aryabinin@virtuozzo.com>
 <20170221134332.GA5052@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        "David S. Miller" <davem@davemloft.net>, <dccp@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        <syzkaller@googlegroups.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40106.outbound.protection.outlook.com ([40.107.4.106]:47104
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754496AbdBVI6J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Feb 2017 03:58:09 -0500
In-Reply-To: <20170221134332.GA5052@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2017 04:43 PM, Arnaldo Carvalho de Melo wrote:
> Em Tue, Feb 21, 2017 at 02:27:40PM +0300, Andrey Ryabinin escreveu:
>> DCCP doesn't purge timewait sockets on network namespace shutdown.
>> So, after net namespace destroyed we could still have an active timer
>> which will trigger use after free in tw_timer_handler():
>>
>>
>> Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
>> timewait sockets on net namespace destruction and prevent above issue.
> 
> Please add this, to help stable kernels to pick this up
> 
> Fixes: b099ce2602d8 ("net: Batch inet_twsk_purge")
> Cc: Eric W. Biederman <ebiederm@xmission.com> 
> 

Fixes tag should blame commit f2bf415cfed7 ("mib: add net to NET_ADD_STATS_BH").
It introduced use of net namespace in the timer callback.
