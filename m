From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: TCP socket timeout after IP address is removed
Date: Fri, 25 Jul 2014 21:04:16 +0100
Message-ID: <53D2B840.4040308@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joby Poriyath <joby.poriyath@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:4879 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932508AbaGYUE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 16:04:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We have a timout problem on TCP sockets, which probably has some trivial 
solution, but I couldn't figure it out after hours of staring at the 
code, so hopefully someone can shed some light on it here.
The scenario is the following:
- I start an ssh connection from host A to B, it works fine
- netstat shows the socket is using local address K
- then I remove local address K, and with DHCP I get a new one, L on a 
different interface (interfaces are always up during the whole time)
- the socket is still alive, but my SSH connection doesn't transmit 
anything, obviously, as netstat says it is still using IP address K
- ftrace showed me the data goes through the TCP layer and finally the 
IP layer drops it because the route is no longer valid

On 3.10 kernel it times out after ~15 minutes or so, which isn't too 
good for me. On 2.6.32 it times out after a couple of minutes, and I 
would like to achieve the same, but I couldn't figure out how. Could 
anyone give me some guidance?

Regards,

Zoltan Kiss
