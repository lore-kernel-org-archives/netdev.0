From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH] vxlan: using AF_PACKET socket to send multicast packet
 cause WARNING
Date: Thu, 3 Apr 2014 13:28:33 +0800
Message-ID: <CADvbK_ftDf_AsbEeF9EViBm68Co3bj1L-fR1-BDA0Uxn=1LPpA@mail.gmail.com>
References: <1396343330-23648-1-git-send-email-lucien.xin@gmail.com>
	<20140401.161047.854771903443514987.davem@davemloft.net>
	<CADvbK_dK_fBB3bQSWKkAk6adtgrHm553Hr3JGHsw67qeS0cQOw@mail.gmail.com>
	<20140402075106.3eec7791@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:48683 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161276AbaDCF2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 01:28:34 -0400
Received: by mail-we0-f169.google.com with SMTP id w62so1255088wes.0
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 22:28:33 -0700 (PDT)
In-Reply-To: <20140402075106.3eec7791@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 2, 2014 at 10:51 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> That breaks local socket accounting for tunneled packets.
It do break, I think it should break, becaue vlxan send UDP packets,
it should be bound to UDP socket.
after  encapsulating the packet with local socket.  it reach the
vxlan's xmit.  and It should be take into
vxlan's UDP socket.and local socket should not take care of it.

now the problem is that the local socket(AF_PACKET) cannot take it to
travel the ipv4/6 protocol stack,
unlike TCP/UDP socket.   perhaps, in later, there will be other type
protocol family that has the same issue.
so I think vxlan should support it.

> The idea is that a TCP socket sending over vxlan will keep it's
> memory accounting all the way until the device sends it.
yes, the idea is there.  But if vxlan is treated as net_device,  the
packet enter it's xmit(), which seems
 to be send by the device.  so when the packet goes there, the TCP
socket also should let it go.

of course, if you insist the idea you said,  to support only some type
protocol family, do you have some
better suggestion?

I cannot be sure I understand you well, those are just my own
thoughts. pls help to check and correct it .  :)

many thanks to your reply.
