From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: Regarding bottlenecks for high speed packet generation
Date: Thu, 25 Oct 2012 20:04:32 +0200
Message-ID: <CAD6jFUTL9-Uyf-0YPwB7Fd5V71NvJh4ameZMF2GCQjDXh_DVzw@mail.gmail.com>
References: <CADAe=+KJ2QuL7ZdrfDWQe8R1vF_r_bu3QBS-5kwZBgQ21QTMtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59319 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513Ab2JYSEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 14:04:43 -0400
Received: from [78.46.4.229] (helo=sslproxy03.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TRRnL-0005RA-KS
	for netdev@vger.kernel.org; Thu, 25 Oct 2012 20:04:39 +0200
Received: from [209.85.215.174] (helo=mail-ea0-f174.google.com)
	by sslproxy03.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TRRnI-0007Uc-Hy
	for netdev@vger.kernel.org; Thu, 25 Oct 2012 20:04:36 +0200
Received: by mail-ea0-f174.google.com with SMTP id c13so601710eaa.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 11:04:33 -0700 (PDT)
In-Reply-To: <CADAe=+KJ2QuL7ZdrfDWQe8R1vF_r_bu3QBS-5kwZBgQ21QTMtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 25, 2012 at 7:46 PM, Ajith Adapa <adapa.ajith@gmail.com> wrote:
> I am trying out a sample application written based on packet_mmap to
> generate packets at line rates. I am using 3.4.10 kernel and a gigabit
> nic card.
> I have found some strange issues as mentioned below.
>
> When I am transmitting packets sized 1500 bytes the socket buffers are
> easily filled up eventhough if I increase the value of wmem_default
> and wmem_max.
> The memory I have allotted can fit around 14k packets of 1500 bytes
> size. Is the NIC card not able to transmit them ?? How can I check it
> ??
> I have even increased the Hardware tx queue size of NIC card from 256
> to 4096 using ethtool.
>
> Does traffic control causing any issue as I read it wont allow traffic bursts ?

Actually in my experience not. On Gigabit Ethernet (depending on your
machine) you should be able to generate about 80k pps with 1500 byte
(e.g. with netsniff-ng's trafgen) having the default tc discipline.

> Is there any way to find the major bottlenecks that would really cause
> problems in high-speed packet generation.

Have you looked how much pps the kernel space pktgen can generate on
your machine with 1500 byte packets?

What tool do you use to measure this reported rate? Do you analyze
driver statistics from e.g. procfs, or do you use a libpcap-based tool
to measure the stuff (which you shouldn't since it could falsify your
stats)? How was your measurement setup?
