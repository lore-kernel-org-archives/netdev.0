From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 1/1] ip-link: add switch to show human readable output
Date: Wed, 29 Oct 2014 22:47:38 -0700
Message-ID: <20141029224738.263e27bd@urahara>
References: <1412980056-7643-1-git-send-email-mail@eworm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christian Hesse <mail@eworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:60855 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755855AbaJ3Frt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 01:47:49 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so4470654pdi.2
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 22:47:49 -0700 (PDT)
In-Reply-To: <1412980056-7643-1-git-send-email-mail@eworm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 11 Oct 2014 00:27:36 +0200
Christian Hesse <mail@eworm.de> wrote:

> Byte and packet count can increase to really big numbers. This adds a
> switch to show human readable output.
> 
> % ip -s link ls wl
> 4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
>     link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     113570876  156975   0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     27290790   94313    0       0       0       0
> % ip -s -h link ls wl
> 4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
>     link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     122368888  169840   0       0       0       0
>     116.7Mi    165.8Ki  0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     29087507   102309   0       0       0       0
>     27.7Mi     99.9Ki   0       0       0       0
> ---

I like the idea as a concept but there are two issues:
  1. The IEC suffix is a rarely used thing and is non-standard
     for communications where K = 1000 M = 1000000 etc.
     Please just use standard suffices

  2. Don't double print the data, if the user asks for human
     format, only show the human format.
