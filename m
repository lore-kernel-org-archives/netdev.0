From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Single socket with TX_RING and RX_RING
Date: Wed, 15 May 2013 15:20:45 +0200
Message-ID: <51938BAD.5050502@redhat.com>
References: <loom.20130515T144941-798@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ricardo_Tub=EDo?= <rtpardavila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932241Ab3EONUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 09:20:52 -0400
In-Reply-To: <loom.20130515T144941-798@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2013 02:53 PM, Ricardo Tub=EDo wrote:
> Once I tell kernel to export the TX_RING through setsockopt() (see co=
de
> below) I always get an error (EBUSY) if i try to tell kernel to expor=
t the
> RX_RING with the same socket descriptor. Therefore, I have to open an
> additional socket for the RX_RING and I require of two sockets when I=
 though
> that I would only require of one socket for both TX and RX using mmap=
()ed
> memory.
>
> Do I need both sockets or am I doing something wrong?

The second time you call init_ring() in your code e.g. with TX_RING, wh=
ere
you have previously set it up for the RX_RING. The kernel will give you
-EBUSY because the packet socket is already mmap(2)'ed.
