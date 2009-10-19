From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: Re: [PATCH] IPv4: skip loopback checksums in ip_rcv()
Date: Mon, 19 Oct 2009 22:56:52 +0200
Message-ID: <200910192256.52780.schmto@hrz.tu-chemnitz.de>
References: <200910192134.02125.schmto@hrz.tu-chemnitz.de> <4ADCCF1A.7070301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.hrz.tu-chemnitz.de ([134.109.132.46]:39643 "EHLO
	jack.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757570AbZJSU4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 16:56:50 -0400
In-Reply-To: <4ADCCF1A.7070301@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrotes:
> This is bogus IMHO.
> 
> One bit could be corrupted in iph, and ntohl(iph->daddr) becomes 0x7fxxyyzz,
> we then accept a bogus frame. This is a RFC violation.
> 
> This also slows down non loopback devices, adding an extra test.
> 
> ip_fast_csum() is really fast (about 16 instructions).

Yes, you are right. So it would be better to only skip csum if *dev is 
our loopback interface ? Right ?
