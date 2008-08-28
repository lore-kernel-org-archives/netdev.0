From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Questions about Linux kernel network programming
Date: Thu, 28 Aug 2008 18:02:07 +0100
Message-ID: <20080828170206.GJ7908@solarflare.com>
References: <3fedcc3b0808280733w1d7b24dgf95540d2078856f8@mail.gmail.com> <3fedcc3b0808280748q4090c5e7n45c74c4fd3b42cca@mail.gmail.com> <379e30200808280803j6a2a86bfya34ecc17127a1bbd@mail.gmail.com> <3fedcc3b0808280919l65131584gf91d656f02e1d7ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tobias Koeck <tobias.koeck@gmail.com>, netdev@vger.kernel.org
To: Thiago Lacerda <thiagotbl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:60388 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753305AbYH1RCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 13:02:12 -0400
Content-Disposition: inline
In-Reply-To: <3fedcc3b0808280919l65131584gf91d656f02e1d7ac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thiago Lacerda wrote:
> Thanks for your replay Tobias.
> 
> But, doing it as a netfilter module I'm going to interfere in all the
> traffic of my PC.
> I don't want to do it that way. I want to capture the packets at
> kernel and then decide if they will be analyzed by my DPI tool at user
> land. My module would act like a filter for my classifier, cause I
> want to don't spend time with unncessary copies of packets to user
> space memory (like libpcap does, it copies every packets).

netfilter modules don't just accept or deny packets.  For example there is
a LOG module which logs some brief information about any packets it
receives.

> I'm doing like this:
> 
> * registered a protocol handler with dev_add_pack
> * in the function in packet_type struct I'm doing some operations with
> the packet, but I'm not passing it to user land yet
> 
> Is that a good way of doing such task?
> Does occur any copy of packets during this operation (the copy I know
> is that one from the NIC to kernel memory, does any other occur?)?

Depends on the driver.

> BTW, anyone knows the right way of get a tcp port number in human readable form?
> I'm doing like this:
> 
> struct tcphdr* tcp = tcp_hdr(my_sk_buff)
> 
> unsigned short src_port = ntohs(tcp->source)
> 
> And it isn't working, the numbers that I get are not right.

Until the packet has gone through the network protocol handler (IP), the
transport header pointer will not be set correctly and tcp_hdr() will return
a pointer to the start of the packet.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
