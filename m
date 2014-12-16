From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [iproute2] tc: Show classes more hierarchically]
Date: Tue, 16 Dec 2014 16:12:41 -0200
Message-ID: <54907619.5080508@gmail.com>
References: <20141215224851.GB6734@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: vadim4j@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:52045 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaLPSMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 13:12:46 -0500
Received: by mail-qg0-f41.google.com with SMTP id j5so10603807qga.0
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 10:12:46 -0800 (PST)
In-Reply-To: <20141215224851.GB6734@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-12-2014 20:48, vadim4j@gmail.com wrote:
> Hi All,
>
> I am playing with showing classes in more hierarchically format and I
> have some code and example of output from my TC looks like:
>
> # tc/tc -t class show dev tap0
>
>   \---1:2 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>          \---1:40 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>          \---1:50 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>          \---1:60 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>   \---1:1 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>          \---1:10 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>                 \---1:11 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>                        \---1:111 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>          \---1:20 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>          \---1:30 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>
>
> which in standart output mode it looks like:
>
> # tc/tc class show dev tap0
>
> class htb 1:11 parent 1:10 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> class htb 1:111 parent 1:11 prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> class htb 1:10 parent 1:1 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> class htb 1:1 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> class htb 1:20 parent 1:1 leaf 20: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> class htb 1:2 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> class htb 1:30 parent 1:1 leaf 30: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> class htb 1:40 parent 1:2 leaf 40: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> class htb 1:50 parent 1:2 leaf 50: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> class htb 1:60 parent 1:2 leaf 60: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>
> So I'd like to ask if it might be useful for the TC users (may be
> better format ?) to have this ?

Good idea! It already looks good, but what about:

   |-- 1:2 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
   |      |-- 1:40 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
   |      |-- 1:50 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
   |      '-- 1:60 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
   |-- 1:1 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
   ...

just another idea..

Thanks.
   Marcelo
