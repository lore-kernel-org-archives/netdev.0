From: Claudio Scordino <claudio@evidence.eu.com>
Subject: Same data to several sockets with just one syscall ?
Date: Fri, 12 Feb 2016 09:53:37 +0100
Message-ID: <CAGWmfYrGv8NdJQHs6OA=b=ao8=25JUoZAK_i65+GMFX1OyV-fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:35265 "EHLO
	mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbcBLIxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 03:53:38 -0500
Received: by mail-vk0-f48.google.com with SMTP id e6so55902678vkh.2
        for <netdev@vger.kernel.org>; Fri, 12 Feb 2016 00:53:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

Suppose I have an application that needs to send the very same data to
several sockets already connected. In this case, the application has
to call the sendto() syscall several times:

      for(...)
               sendto(...)

This makes the application waste time in entering/exiting the kernel
level several times.
Moreover, if I'm not wrong, the kernel is free to execute pending work
(e.g., softirqs) when returning from a syscall, making the application
experience further latency.

I therefore wonder if a mechanism exists for sending the data to
several sockets using just a single syscall. If not, has anybody ever
thought about adding a syscall like the following ?

      sendto-multicast(..., int number_of_sockets, int* const sockets [])

I can't see any obvious reason why such an approach could be wrong.

Many thanks,

               Claudio
