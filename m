From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: Hit regression with TCP_TW REUSE/RECYCLE
Date: Fri, 20 Nov 2015 11:14:58 +0800
Message-ID: <CABawtvONnog5_e3p5vWtbStUDdiz==uKeQvNzZLV6+PizUSzQw@mail.gmail.com>
References: <CABawtvO_b_zofYfCgGA2oF5VhPtWAsaD4FNsSexzf8pPy6k4iw@mail.gmail.com>
	<CABawtvPOYUAqwF2j_dZWMfkmcee+2LV00si2cbVs9zqYBZ6Ynw@mail.gmail.com>
	<1447762069.22599.88.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447762069.22599.88.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric,


On Tue, Nov 17, 2015 at 8:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-11-17 at 14:35 +0800, Ethan Zhao wrote:
>> Tested the same case with 4.4-RC1, it was fixed in 4.4-RC1.
>> But don't know which commit fixed it.
>>
>>  # echo 1024 65535 > /proc/sys/net/ipv4/ip_local_port_range
>>  # cat /proc/sys/net/ipv4/ip_local_port_range
>> 1024    65535
>>  # echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
>>  #  cat /proc/sys/net/ipv4/tcp_tw_reuse
>> 1
>>  # echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle
>>  #  cat /proc/sys/net/ipv4/tcp_tw_reuse
>> 1
>>  # ./accept -n 5 -r &
>> [1] 11866
>>  # port: 7954
>> ninst: 5
>> reuseport: 1
>>
>>  # ./connect -i 127.0.0.1 -n 5 -d 10
>> 78578.50
>>  # uname -a
>> Linux localhost.localdomain 4.4.0-rc1 #49 SMP Tue Nov 17 15:04:18 KST
>> 2015 x86_64 x86_64 x86_64 GNU/Linux
>
> Maybe run a reverse bisection ?

 Hmmm,  will do.
>
> tcp_tw_reuse and tcp_tw_recycle both set to one have never been
> supported in linux.
>
> tcp_tw_recycle - BOOLEAN
>         Enable fast recycling TIME-WAIT sockets. Default value is 0.
>         It should not be changed without advice/request of technical
>         experts.
>
> tcp_tw_reuse - BOOLEAN
>         Allow to reuse TIME-WAIT sockets for new connections when it is
>         safe from protocol viewpoint. Default value is 0.
>         It should not be changed without advice/request of technical
>         experts.
>
> Thanks.
>
>

Thanks,
Ethan
