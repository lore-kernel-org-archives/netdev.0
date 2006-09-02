From: "Gary Chan" <hpchan5@ie.cuhk.edu.hk>
Subject: Re: Linux UDP Implementation
Date: Sat, 2 Sep 2006 14:27:20 +0800
Message-ID: <04d201c6ce58$d8744420$193aa8c0@mclabhpchan5>
References: <00f401c6ccc2$40ad2a90$193aa8c0@mclabhpchan5> <44F715B5.5070905@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="big5";
	reply-type=response
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from eng.ie.cuhk.edu.hk ([137.189.96.20]:39653 "EHLO
	eng.ie.cuhk.edu.hk") by vger.kernel.org with ESMTP id S1750809AbWIBG1Y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 02:27:24 -0400
Received: from viruswall2.ie.cuhk.edu.hk (IDENT:U2FsdGVkX18LCJxAPyWJw/64A9w58LIafS3J7Cz+GqU@viruswall2 [137.189.96.53])
	by eng.ie.cuhk.edu.hk (8.13.6/8.13.6) with ESMTP id k826RKUe032133
	for <netdev@vger.kernel.org>; Sat, 2 Sep 2006 14:27:21 +0800
To: "Rick Jones" <rick.jones2@hp.com>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Rick,

Thank you for your reply.

I am sorry that I don't quite understand your point. As far as I know, the 
function call udp_flush_pending_frames() in net/ipv4/udp.c is invoked 
regardless of whether the socket is set to either a blocking mode or a 
non-blocking mode. Do you mean that the implementation in the function 
sendto() handles the packet drop at the interface queue by caching data at 
the socket level ? If so, could you please advise me the Linux Kernel source 
file which contains the exact implementation of sendto() API function call 
in Linux ? I tried to locate this souce file using a bottom-up approach 
starting at the function call udp_sendmsg(), -> inet_sendmsg()  in 
net/ipv4/af_inet.c -> sock_sendmsg() in net/socket.c-> sys_sendto() in 
net/socket.c ... but I finally got lost in sys_sendto().

Thank you for your help.

Regards,

Gary

----- Original Message ----- 
From: "Rick Jones" <rick.jones2@hp.com>
To: "Gary Chan" <hpchan5@ie.cuhk.edu.hk>
Sent: Friday, September 01, 2006 1:00 AM
Subject: Re: Linux UDP Implementation


> Gary Chan wrote:
>> According to the function call udp_sendmsg() in the source file 
>> net/ipv4/udp.c (Linux Kernel 2.6.17.11), when an error value is returned 
>> from the function ip_append_data() due to local device congestion, say 
>> interface queue overflow,  pending packets in the queue 
>> sk->sk_write_queue are simply flushed (udp_flush_pending_frames() is 
>> invoked) without caching for future retransmission.
>>
>> I called a network API function sendto() to transmit UDP packets in a 
>> blocking I/O mode at a rate of 100Mbps over the 802.11b wireless ad hoc 
>> network, the network was overloaded as the maximum transfer rate for 
>> 802.11b was just 11Mbps. Therefore, the outgoing interface queue must be 
>> full and UDP packets will be dropped eventually. However, I checked that 
>> there was no packet loss at the receiver side, i.e. the number of packets 
>> sent from the sender is equal to that received.
>>
>> It seems that the implementation (at code level) does not match with the 
>> actual behaviour. I would like to seek expertise on clarifying my 
>> understanding in UDP implementation so that this phenomenon can be 
>> explained.
>
> Perhaps you are seeing a difference in the behaviour of blocking vs 
> non-blocking sockets?
>
> rick jones 


-- 
VGER BF report: U 0.5
