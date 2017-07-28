From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCHv4 net] ipv6: no need to check rt->dst.error when get route
 info
Date: Fri, 28 Jul 2017 11:23:06 -0600
Message-ID: <7a1cbc32-34de-a3c3-ee4b-09c3c714a952@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
 <9e5d3137-c84d-91f7-6c82-813519964513@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35928 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751882AbdG1RXJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 13:23:09 -0400
Received: by mail-pg0-f67.google.com with SMTP id y129so24184231pgy.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 10:23:09 -0700 (PDT)
In-Reply-To: <9e5d3137-c84d-91f7-6c82-813519964513@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/17 12:03 PM, David Ahern wrote:
> On 7/27/17 10:25 AM, Hangbin Liu wrote:
>> After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
>> result when requested"). When we get a prohibit ertry, we will return
>> -EACCES directly instead of dump route info.
>>
>> Fix it by remove the rt->dst.error check.
>>
>> Before fix:
>> \# ip -6 route add prohibit 2003::/64 dev eth1
>> \# ip -6 route get fibmatch 2003::1
>> RTNETLINK answers: Permission denied
>> \# ip -6 route add unreachable 2004::/64 dev eth1
>> \# ip -6 route get fibmatch 2004::1
>> RTNETLINK answers: No route to host
>>
>> After fix:
>> \# ip -6 route add prohibit 2003::/64 dev eth1
>> \# ip -6 route get fibmatch 2003::1
>> prohibit 2003::/64 dev lo metric 1024 error -13 pref medium
>> \# ip -6 route add unreachable 2004::/64 dev eth1
>> \# ip -6 route get fibmatch 2004::1
>> unreachable 2004::/64 dev lo metric 1024 error -113 pref medium
>>
>> Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
>> ---
>>  net/ipv6/route.c | 6 ------
>>  1 file changed, 6 deletions(-)
>>
> 
> Acked-by: David Ahern <dsahern@gmail.com>
> 

Dave: please hold off on applying this patch.
