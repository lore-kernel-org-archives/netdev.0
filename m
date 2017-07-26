From: Klavs Klavsen <kl@vsen.dk>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 14:18:14 +0200
Message-ID: <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
 <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jaina.enableit.dk ([109.238.49.194]:59696 "EHLO
        kolab01.enableit.idk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751775AbdGZMSc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 08:18:32 -0400
In-Reply-To: <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the 192.168.32.44 is a Centos 7 box.

Could you help me by elaborating on how to see why the "dup ack" (sack 
blocks) are bogus?

Thank you very much. I'll try to capture the same scp done on mac - and 
see if it also gets DUP ACK's - and how they look in comparison (since 
it works on Mac clients).

Eric Dumazet skrev den 2017-07-26 13:49:
> On Wed, 2017-07-26 at 13:07 +0200, Klavs Klavsen wrote:
>> Hi guys,
>> 
>> Me and my colleagues have an annoying issue with our Linux desktops 
>> and
>> the company's Junos VPN.
>> 
>> We connect with openconnect (some use the official Pulse client) - 
>> which
>> then opens up a tun0 device - and traffic runs through that.
>> 
>> If we try to scp a file of ~100MB (f.ex. linux-4.12.3.tar.xz :) - it
>> stalls after sending 20-30% typicly.. then starts again after some 
>> time,
>> and typicly dies before finishing. I've captured it with tcpdump (its 
>> a
>> large 77Mb file - thats how far it got before it died :) -
>> http://blog.klavsen.info/fast-retransmit-problem-junos-linux
>> 
>> I've attached an image of wireshark - where the (AFAIK) interesting 
>> part
>> starts.. Where my client starts getting DUP ACK's.. but my Linux 
>> client
>> does nothing :(
>> I've tried to upgrade to latest Ubuntu-mainline kernel build (4.12.3)
>> and it changed nothing.
>> 
>> The problem goes away, if I do:
>> sysctl -w net.ipv4.tcp_sack=0
>> 
>> I've tried specificly enabling net.ipv4.tcp_fack=1 - but that did not
>> help.
>> 
>> This is not an issue on Mac OSX or Windows clients.
>> 
>> None of the Linux users here figured, that could be a Linux kernel 
>> issue
>> - but the evidence seems to suggest it - and all my googleing and
>> reading does not lead me to any other conclusion.
>> 
>> It may ofcourse be that Junos has implemented the standard 
>> badly/wrongly
>> - and Windows/Mac has done a workaround for that?
>> 
>> I hope you can help me figure out whats going wrong.
>> 
> 
> sack blocks returned by the remote peer are completely bogus.
> 
> Maybe a firewall is messing with them ?
> 
> I suspect ACK packets might be simply dropped because of invalid SACK
> information.

-- 
Regards,
Klavs Klavsen, GSEC - kl@vsen.dk - http://blog.klavsen.info - Tlf. 
61281200

"Those who do not understand Unix are condemned to reinvent it, poorly."
   --Henry Spencer
