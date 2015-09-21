From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute2 net-next] ip route: Add RTM_F_LOOKUP_TABLE flag and
 show table id
Date: Mon, 21 Sep 2015 16:23:13 -0600
Message-ID: <56008351.7010005@cumulusnetworks.com>
References: <56007695.3070003@cumulusnetworks.com>
 <20150921.145800.1946648892912159723.davem@davemloft.net>
 <56007E94.8000506@cumulusnetworks.com>
 <20150921.150346.926573540048522271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36807 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932632AbbIUWXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 18:23:08 -0400
Received: by padbj2 with SMTP id bj2so3264671pad.3
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 15:23:07 -0700 (PDT)
In-Reply-To: <20150921.150346.926573540048522271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/15 4:03 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Mon, 21 Sep 2015 16:03:00 -0600
>
>> On 9/21/15 3:58 PM, David Miller wrote:
>>> I think if it always gave MAIN in older kernels, iproute should
>>> continue
>>> to do so.
>>>
>>> You can't just remove the table ID output just because you disagree
>>> with
>>> the semantics given by old kernels.
>>>
>>
>> Current semantics are maintained. Kernel was hardcoded to return main;
>> iproute2 was hardcoded to not show main.
>
> Since iproute2 always showed MAIN, it should conitnue to do so when
> run on older kernels.
>
> And again this is regardless of whether you disagree with those
> semantics or not.
>

Dave:

ip does *not* show the table id or string today:

root@vm-wheezy2:~# ip route get 10.2.1.254
10.2.1.254 dev eth1 src 10.2.1.2
cache


With the new flag a AND kernel that supports it ip will only show the 
table id IF it is not main:

root@vm-wheezy2:~# ./ip route get 10.0.0.20
10.0.0.20 dev eth0  src 10.0.0.2
     cache

root@vm-wheezy2:~# ./ip route get 10.2.1.254
10.2.1.254 dev eth1  table 10  src 10.2.1.2
     cache

That's my point. I have not changed existing users.
