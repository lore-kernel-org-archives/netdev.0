From: "Holger Hoffstaette" <holger@wizards.de>
Subject: Re: Reproducible data corruption with sendfile+vsftp - splice regression?
Date: Sun, 02 Dec 2007 21:49:42 +0100
Message-ID: <pan.2007.12.02.20.49.42.675000@wizards.de>
References: <pan.2007.11.29.23.42.52.661624@wizards.de> <474FC4D9.3020506@cosmosbay.com> <pan.2007.11.30.09.20.24.737500@wizards.de> <475055EE.9060105@hp.com> <pan.2007.12.02.16.00.03.568000@wizards.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:37479 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751526AbXLBUvK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2007 15:51:10 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Iyvlg-0007My-6k
	for netdev@vger.kernel.org; Sun, 02 Dec 2007 20:50:24 +0000
Received: from port-87-234-135-174.dynamic.qsc.de ([87.234.135.174])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 02 Dec 2007 20:50:24 +0000
Received: from holger by port-87-234-135-174.dynamic.qsc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 02 Dec 2007 20:50:24 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 Dec 2007 17:00:03 +0100, Holger Hoffstaette wrote:

> On Fri, 30 Nov 2007 10:26:54 -0800, Rick Jones wrote:
> 
>> Could the corruption be seen in a tcpdump trace prior to transmission
>> (ie taken on the sender) or was it only seen after the data passed out
>> the NIC?
> 
> I did the following:
> 
> 1) turn on tso on the server's r8169: ethtool --offload eth0 tso on
> 2) on the server: tcpdump -i eth0 -s 0 -w <file>
> 3) ftp'ed file to 100mbit client
> 
> As expected the file was corrupted, and the various corrupted byte
> sequences also show up in the tcpdump file at the corresponding offsets.
> 
> I did this with 2.6.22.14, so it does not seem to be a recent regression
> in .23/.24.
> 
> All files can be found here:
> http://hoho.dyndns.org/~holger/dist/r8169-tso/
> 
> I will gladly try out any other tweaks but need some guidance as I don't
> know what exactly to change - maybe without NAPI for the r8169?

Ta-daa! Rebuilding 2.6.22.14 (and I suspect all other versions) without
NAPI for the r8169 but with tso enabled yields NO data corruption; the
ftp'ed file has a good crc, repeatedly.

Any suggestions how to proceed? Should I file this in bugzilla?

thanks
Holger


