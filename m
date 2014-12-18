From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [iproute2] tc: Show classes more hierarchically]
Date: Wed, 17 Dec 2014 23:56:04 -0200
Message-ID: <54923434.3030209@gmail.com>
References: <20141215224851.GB6734@angus-think.lan> <54907619.5080508@gmail.com> <20141217115535.3f5198d2@urahara> <20141217235627.GA2149@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:39109 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbaLRB4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 20:56:11 -0500
Received: by mail-qc0-f170.google.com with SMTP id x3so214672qcv.15
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 17:56:10 -0800 (PST)
In-Reply-To: <20141217235627.GA2149@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-12-2014 21:56, Vadim Kochan wrote:
> On Wed, Dec 17, 2014 at 11:55:35AM -0800, Stephen Hemminger wrote:
>> On Tue, 16 Dec 2014 16:12:41 -0200
>> Marcelo Ricardo Leitner <marcelo.leitner@gmail.com> wrote:
>>
>>> On 15-12-2014 20:48, vadim4j@gmail.com wrote:
>>>> Hi All,
>>>>
>>>> I am playing with showing classes in more hierarchically format and I
>>>> have some code and example of output from my TC looks like:
>>>>
>>>> # tc/tc -t class show dev tap0
>>>>
>>>>    \---1:2 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>           \---1:40 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>           \---1:50 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>           \---1:60 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>    \---1:1 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>           \---1:10 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>                  \---1:11 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>                         \---1:111 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>           \---1:20 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>           \---1:30 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>
>>>>
>>>> which in standart output mode it looks like:
>>>>
>>>> # tc/tc class show dev tap0
>>>>
>>>> class htb 1:11 parent 1:10 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
>>>> class htb 1:111 parent 1:11 prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>> class htb 1:10 parent 1:1 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
>>>> class htb 1:1 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
>>>> class htb 1:20 parent 1:1 leaf 20: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
>>>> class htb 1:2 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
>>>> class htb 1:30 parent 1:1 leaf 30: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>> class htb 1:40 parent 1:2 leaf 40: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
>>>> class htb 1:50 parent 1:2 leaf 50: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
>>>> class htb 1:60 parent 1:2 leaf 60: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>>
>>>> So I'd like to ask if it might be useful for the TC users (may be
>>>> better format ?) to have this ?
>>>
>>> Good idea! It already looks good, but what about:
>>>
>>>     |-- 1:2 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>     |      |-- 1:40 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>     |      |-- 1:50 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>     |      '-- 1:60 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>     |-- 1:1 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>>>     ...
>>>
>>> just another idea..
>>>
>>> Thanks.
>>>     Marcelo
>>
>> There are several places that also print tree format, hopefully there would
>> be reusable code (lspci, tree, ps).
>>
>
> OK, currently I have the following output:
>
> +---1:2(htb) rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> |   +---1:40(htb) prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> |   +---1:50(htb) prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> |   +---1:60(htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> |
> +---1:1(htb) rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
>      +---1:10(htb) rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
>      |   +---1:11(htb) rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
>      |   |   +---1:111(htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>      |   |   +---1:112(htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>      |   |
>      |   +---1:12(htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>      |
>      +---1:20(htb) prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
>      +---1:30(htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>
> How about this ?

Looks very good to me, thanks!

> Regards,
> Vadim Kochan
>
