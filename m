From: slavon@bigtelecom.ru
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Tue, 15 Jan 2008 19:11:09 +0300
Message-ID: <20080115191109.j54rx0t008k8wook@mail.bigtelecom.ru>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:58823 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbYAOQLM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 11:11:12 -0500
In-Reply-To: <478CD9D6.3000504@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I understand. Thanks!

> Badalian Vyacheslav wrote:
>> Hello all. Have packetlost when do "tc qdisc del dev eth0 root".
>>
>> look:
>>
>> slavon ~ # ping -f 87.255.1.134
>> PING 87.255.1.134 (87.255.1.134) 56(84) bytes of data.
>> .
>> .....................................................................................................................................................................................................................................................................   
>> .
>> --- 87.255.1.134 ping statistics ---
>> 60811 packets transmitted, 60544 received, 0% packet loss, time 39528ms
>> rtt min/avg/max/mdev = 0.203/0.579/3227.655/13.124 ms, pipe 219,   
>> ipg/ewma 0.650/2.197 ms
>>
>> Its normal?
>
> Yes, packets in the old qdisc are lost.
>
>> Maybe if tc do changes - need create second queue (hash of rules or  
>>  how you named it?) and do changes at it. Then replace old queue   
>> rules by created new.
>> Logic -
>> 1. Do snapshot
>> 2. Do changes in shapshot
>> 3. All new packets go to snapshot
>> 4. If old queue not have packets - delete it.
>> 5. Snapshot its default.
>
>
> That doesn't really work since qdiscs keep internal state that
> in large parts depends on the packets queued. Take the qlen as
> a simple example, the new qdisc doesn't know about the packets
> in the old one and will exceed the limit.



----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

