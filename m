From: Kevin Spiteri <kspiteri@ieee.org>
Subject: Re: TCP checksum error on local device
Date: Wed, 09 Jul 2008 17:28:54 +0200
Message-ID: <4874D936.9020100@ieee.org>
References: <9a6873fa0807090734ge7ef12lf09e78db44ba77f5@mail.gmail.com> <20080709151019.GG27741@nereid>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:57067 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774AbYGIP1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 11:27:32 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1568207fkq.5
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2008 08:27:30 -0700 (PDT)
In-Reply-To: <20080709151019.GG27741@nereid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kristof Provost wrote:
> On 2008-07-09 16:34:32 (+0200), Kevin Spiteri <kspiteri@ieee.org> wrote:
>   
>> When I send TCP data from localhost to localhost (either on 127.0.0.1
>> or on the public IP of the machine), the TCP checksum is wrong.
>>
>>     
> I suspect this is intended and expected behaviour. The checksum is quite
> useless as the packet never travels over the network and can't be
> corrupted. 
>   
Probably.

I saw the behaviour as strange because only the segment containing data 
had an incorrect TCP checksum, all other segments (SYN, SYN ACK, ACKs 
without data and FIN ACK) had a correct TCP checksum.

Also, the incorrect checksum field seems to depend on the IP address and 
the packet length, but not on the port number, sequence/acknowledgement 
number or data content. Thus, the incorrect checksum is the same when 
the sample is run repeatedly, it only changes when the data length 
and/or IP address are changed.
> The transmit code in net/ipv4/ip_output.c seems to mark packets for the
> loopback interface with CHECKSUM_UNNECESSARY.
>   
The same happens when I bind the server socket on the public IP (e.g. 
10.111.110.71:12345) and connect from a socket on the same IP 
(10.111.110.71). But then, although the IP is for device eth0 rather 
than for device lo, the packet still never has to be transmitted and the 
checksum is still unnecessary.
> I guess the connection over loopback still carries the data like you'd
> expect right?
>   
Yes, the data was still received and correct.

Kevin

