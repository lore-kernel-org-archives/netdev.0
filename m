From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: conntrack, NAT and icmp echo reply
Date: Thu, 11 Oct 2012 13:02:20 +0300
Message-ID: <10293136eb284457b47cbffd6c91d1ef@visp.net.lb>
References: <e457eb3b6f3e357c3681c7af5f504161@visp.net.lb>
 <1349949430.21172.8435.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <netfilter@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1349949430.21172.8435.camel@edumazet-glaptop>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012-10-11 12:57, Eric Dumazet wrote:
> On Thu, 2012-10-11 at 12:41 +0300, Denys Fedoryshchenko wrote:
>> Hi all
>>
>> I have NAT box, with very simple rule
>> iptables -t nat -I POSTROUTING -s 10.0.0.0/8 -j MASQUERADE
>> It can be SNAT also, and it works fine, as NAT.
>>
>> When i generate icmp _reply_ packet, to some host
>> hping -I ppp0 -1 --icmptype 0 8.8.8.8
>>
>> It will pass the box, and will exit it without NAT, e.g. with 
>> original
>> IP 10.x.x.x
>> on outgoing interface, which is not expected behavior IMHO.
>> Is it a bug or feature?
>>
>
> It depends, -s 10.0.0.0/8 wont match the rule if the source address
> should be 198.23.44.55 I guess ?
>
> I would try the more obvious
>
> iptables -t nat -I POSTROUTING -o device -j MASQUERADE
Source is correct, it is 10.0.0.0/8 range. I tested also ICMP code 3, 
it wont be NATed also.
But ICMP echo passing OK.
Also TCP RST generated same way, (i guess that don't have any match in 
conntrack table), won't be NATed too.
hping -I ppp0 -R 8.8.8.8
13:01:07.074134 IP 10.0.0.142.2106 > 8.8.8.8.0: Flags [R], seq 
510333079, win 512, length 0
13:01:08.074239 IP 10.0.0.142.2107 > 8.8.8.8.0: Flags [R], seq 
1169580528, win 512, length 0
13:01:09.074253 IP 10.0.0.142.2108 > 8.8.8.8.0: Flags [R], seq 
186548661, win 512, length 0
13:01:10.074376 IP 10.0.0.142.2109 > 8.8.8.8.0: Flags [R], seq 
2135508128, win 512, length 0
13:01:11.074553 IP 10.0.0.142.2110 > 8.8.8.8.0: Flags [R], seq 
1507433100, win 512, length 0

And ICMP here you can see correct behavior with icmp echo request:

12:58:22.917458 IP 10.0.0.142 > 8.8.8.8: ICMP echo reply, id 62548, seq 
0, length 8
12:58:23.917543 IP 10.0.0.142 > 8.8.8.8: ICMP echo reply, id 62548, seq 
256, length 8
12:58:24.917657 IP 10.0.0.142 > 8.8.8.8: ICMP echo reply, id 62548, seq 
512, length 8
12:58:31.047475 IP 10.0.0.142 > 8.8.8.8: ICMP net 5.6.7.8 unreachable, 
length 36
12:58:32.047562 IP 10.0.0.142 > 8.8.8.8: ICMP net 5.6.7.8 unreachable, 
length 36
12:58:33.047734 IP 10.0.0.142 > 8.8.8.8: ICMP net 5.6.7.8 unreachable, 
length 36
12:58:54.014601 IP X.146.153.X > 8.8.8.8: ICMP echo request, id 10462, 
seq 0, length 8
12:58:54.081897 IP 8.8.8.8 > X.146.153.X: ICMP echo reply, id 10462, 
seq 0, length 8

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
