From: Madhvapathi Sriram <sriram.madhvapathi@gmail.com>
Subject: Re: IPV4 TCP connection reset using iperf
Date: Fri, 18 Jan 2013 09:43:16 +0530
Message-ID: <CAAvRe=g23ZcZn2dHgQxbC+WmQPRkg40UwcqvcujX-FgneXt7sQ@mail.gmail.com>
References: <CAAvRe=izMJWEFDcZYEoJCY2Em7NQKco4_6x1L7t4h2XSJf6_Sg@mail.gmail.com>
	<50EC59D8.9000701@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:57651 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798Ab3ARENR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 23:13:17 -0500
Received: by mail-ie0-f178.google.com with SMTP id c12so5735761ieb.23
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 20:13:16 -0800 (PST)
In-Reply-To: <50EC59D8.9000701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I was looking into the driver code and found that the problem was with
merging the code and had messed up with skb_put in the receive path. I
have corrected that and everything works fine.
Thanks for the help.

Regards,
Madhvapathi Sriram

On Tue, Jan 8, 2013 at 11:09 PM, Rick Jones <rick.jones2@hp.com> wrote:
> On 01/08/2013 06:41 AM, Madhvapathi Sriram wrote:
>>
>> Hi,
>>
>> I have recently migrated to kernel version 3.6.10 from 3.2.1. I was
>> running iperf to routinely measure TCP throughput and I have been
>> facing problems eversince. I am using a wireless interface.
>>
>> wireless client: iperf -s -i 1 -w 1024K
>> wireless server: iperf -c 192.168.1.1 -i -1 -w 1024 -t 600
>>
>> While, the connection is maintained for sometime and the perf logs
>> keep going. Randomly, the connection breaks with the server side
>> resetting the connection. The tcp dump on the client shows RST sent by
>> the server. Switching back to 3.2.1 works. This issue starts from
>> kernel version 3.5 onnwards.
>>
>> I have tried to probe along some points to take a look at the air
>> logs, tcpdump on either sides but to no clue - everything seems normal
>> like, the tcp window values, very less/negligible retransmissions and
>> so on. The RST is set abruptly and randomly (no definite time - may
>> happen randomly).
>>
>> I am looking for some suggestions or pointers towards analyzing the issue.
>
>
> I cannot imagine that iperf bulk transfer would look all that much different
> from netperf bulk transfer, but I suppose you could see if a netperf
> TCP_STREAM test with similar configuration settings encounters the same RST
> issues.  Or, for that matter, an equally long-lived FTP or scp transfer.
>
> rick jones
>
