From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: TCP communication for raw image transmission
Date: Mon, 2 Jan 2012 16:21:10 +0100
Message-ID: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33382 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328Ab2ABPVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 10:21:32 -0500
Received: by wgbdr13 with SMTP id dr13so26716123wgb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 07:21:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am currently working on a way to send raw images (~400*300 YUV
4:2:0) at a relative high speed (raw image and not compressed image
due to specific codec issues).
This would represent about 57MBps/sec on a 100Mbps ethernet link.
This link is direct, nothing else will pass through it.

My question is a performance and efficiency question. Here is what I
am thinking about :
- I have the image on one computer at a known memory adress
- I want top transmit this picture using TCP packets with the rule
"1row = 1packet", maybe "2rows=1packet"
- All these packets have to go on an ethernet link and will be
received on another computer starting at a known memory adress
Something like this :
http://imageshack.us/photo/my-images/15/tcpmemory.png/

I was thinking about using TCP socket (of course) and the sendfile
syscall on sender side, splice syscall on the receiver side, but I
don't know if this is the best (and fastest) way to do it ?
I would like to avoid memory copy as much as possible as the systems
on which it will be done are embedded arm computers.
TCP is chosen in order to get ordered packets, but maybe am I wrong ?

Thanks for any clues you can give !
Regards,
JM
