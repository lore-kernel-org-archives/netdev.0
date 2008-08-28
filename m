From: "Thiago Lacerda" <thiagotbl@gmail.com>
Subject: Re: Questions about Linux kernel network programming
Date: Thu, 28 Aug 2008 13:19:55 -0300
Message-ID: <3fedcc3b0808280919l65131584gf91d656f02e1d7ac@mail.gmail.com>
References: <3fedcc3b0808280733w1d7b24dgf95540d2078856f8@mail.gmail.com>
	 <3fedcc3b0808280748q4090c5e7n45c74c4fd3b42cca@mail.gmail.com>
	 <379e30200808280803j6a2a86bfya34ecc17127a1bbd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Tobias Koeck" <tobias.koeck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:61733 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbYH1QT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 12:19:57 -0400
Received: by gxk9 with SMTP id 9so4759264gxk.13
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2008 09:19:56 -0700 (PDT)
In-Reply-To: <379e30200808280803j6a2a86bfya34ecc17127a1bbd@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your replay Tobias.

But, doing it as a netfilter module I'm going to interfere in all the
traffic of my PC.
I don't want to do it that way. I want to capture the packets at
kernel and then decide if they will be analyzed by my DPI tool at user
land. My module would act like a filter for my classifier, cause I
want to don't spend time with unncessary copies of packets to user
space memory (like libpcap does, it copies every packets).

I'm doing like this:

* registered a protocol handler with dev_add_pack
* in the function in packet_type struct I'm doing some operations with
the packet, but I'm not passing it to user land yet

Is that a good way of doing such task?
Does occur any copy of packets during this operation (the copy I know
is that one from the NIC to kernel memory, does any other occur?)?

BTW, anyone knows the right way of get a tcp port number in human readable form?
I'm doing like this:

struct tcphdr* tcp = tcp_hdr(my_sk_buff)

unsigned short src_port = ntohs(tcp->source)

And it isn't working, the numbers that I get are not right.

reagards

On Thu, Aug 28, 2008 at 12:03 PM, Tobias Koeck <tobias.koeck@gmail.com> wrote:
> Of course you can code a netfilter target extension module. Changing
> the main kernel network code directly is not necessairy.
>
> Check out the pdf for writing such modules under
>
> http://jengelh.medozas.de/
>
> Check out the
> Greetings
> t.
>
> On Thu, Aug 28, 2008 at 4:48 PM, Thiago Lacerda <thiagotbl@gmail.com> wrote:
>> Hi everyone, I'm a Computer Science student from Brazil.
>>
>> Hope that you can help me with my undergraduate conclusion project.
>>
>> I have to capture packets at kernel level. More specifically, I have
>> to write a kernel module (for kernel 2.6) that access all the packets
>> that are coming through my network interface, then perform some
>> operations on that packets and then decide if they can go to user land
>> or not.
>>
>> Please note that I can't do it as a firewall, because I can't
>> interfere on the  applications that  work with network. My kernel
>> module will get communicated with traffic classifier, that will be
>> executing at user land and will inspect the packets that the module
>> passed to it.
>>
>> Can you help me on how can I develop it?
>>
>> Thanks in advance
>>
>> Best regards
>>
>>
>> --
>> Thiago de Barros Lacerda
>> Computer Science Undergraduate Student - CIn/UFPE - 2004.2
>> Researcher/Software Developer - GPRT - Networking and
>> Telecommunications Research Group
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>



-- 
Thiago de Barros Lacerda
Computer Science Undergraduate Student - CIn/UFPE - 2004.2
Researcher/Software Developer - GPRT - Networking and
Telecommunications Research Group
