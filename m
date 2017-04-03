From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Mon, 03 Apr 2017 15:14:04 +0300
Message-ID: <194a53b80a3cd7fcc360ecf4e1dbf692@nuclearcat.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
 <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170402114545.GA31804@breakpoint.cc>
 <1491134084.10124.6.camel@edumazet-glaptop3.roam.corp.google.com>
 <1491135593.10124.9.camel@edumazet-glaptop3.roam.corp.google.com>
 <4442718191e17f0ff91bf1359da6d631@nuclearcat.com>
 <1491136344.10124.10.camel@edumazet-glaptop3.roam.corp.google.com>
 <f005315a672d82fae34f932f4a7f3d5f@nuclearcat.com>
 <1491153268.10124.12.camel@edumazet-glaptop3.roam.corp.google.com>
 <1491153972.10124.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <35bef48734458fd995d9d4080da5db22@nuclearcat.com>
 <1491221343.10124.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:39162 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752141AbdDCMOI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Apr 2017 08:14:08 -0400
In-Reply-To: <1491221343.10124.16.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-04-03 15:09, Eric Dumazet wrote:
> On Mon, 2017-04-03 at 11:10 +0300, Denys Fedoryshchenko wrote:
> 
>> I modified patch a little as:
>> if (th->doff * 4 < sizeof(_tcph)) {
>>   par->hotdrop = true;
>>   WARN_ON_ONCE(!tcpinfo->option);
>>   return false;
>> }
>> 
>> And it did triggered WARN once at morning, and didn't hit KASAN. I 
>> will
>> run for a while more, to see if it is ok, and then if stable, will try
>> to enable SFQ again.
> 
> Excellent news !
> We will post an official fix today, thanks a lot for this detective 
> work
> Denys.
I am not sure it is finally fixed, maybe we need test more?
I'm doing extensive tests today with identical configuration (i had to 
run fifo, because customer cannot afford anymore outages). I've dded sfq 
now different way, and identical config i will run after 3 hours approx.
