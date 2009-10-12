From: Brian Haley <brian.haley@hp.com>
Subject: Re: Ping Is Broken
Date: Mon, 12 Oct 2009 19:30:26 -0400
Message-ID: <4AD3BC12.6020409@hp.com>
References: <7e84ed60910090316ne9224fat81d9c79c58fc713b@mail.gmail.com>	 <7e84ed60910090934y2a0d422cr158aa8d15e452f97@mail.gmail.com> <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com> <4AD39342.7090209@hp.com> <4AD3A388.7020709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rob.Townley@gmail.com, netdev@vger.kernel.org,
	Omaha Linux User Group <olug@olug.org>,
	CentOS mailing list <centos@centos.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:29098 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757784AbZJLXbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 19:31:06 -0400
In-Reply-To: <4AD3A388.7020709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jarek Poplawski wrote:
> Brian Haley wrote, On 10/12/2009 10:36 PM:
> 
>> In this case ping is doing an SO_BINDTODEVICE to eth0, so the kernel is going
>> to force the packets out of it, even if it isn't the "correct" interface.  If
>> you ran tcpdump you'd probably see an ARP resolution failure, or an ICMP from
>> a gateway.
> 
> BTW, SO_BINDTODEVICE is used only to acquire a source address, not the real
> connection (unless I miss something).

No, SO_BINDTODEVICE affects routing, as well as incoming packets - it's in macros
like INET_MATCH(), from what I've seen it restricts a socket to only use the device
specified, irregardless of the source address you're using.  For example, you can
bind to 127.0.0.1 and send packets out eth0 if sk_bound_dev_if is set to it if I
remember correctly.

-Brian
