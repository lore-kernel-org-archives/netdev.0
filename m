From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Fri, 22 Sep 2006 15:35:17 +0400
Message-ID: <20060922113517.GA32378@2ka.mipt.ru>
References: <20060922112948.GA17335@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:8591 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750837AbWIVLfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 07:35:22 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.7/8.13.7) with ESMTP id k8MBZHk2000532
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 15:35:20 +0400
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.13.7/8.12.1/Submit) id k8MBZHpT000531
	for netdev@vger.kernel.org; Fri, 22 Sep 2006 15:35:17 +0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060922112948.GA17335@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 03:29:48PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Hello.
> 
> I've found strange behaviour of transport mode IPsec in 2.6.18 tree.
> After key daemons exchanged keys (I use racoon) I try following command
> on 2.6.18 machine: telnet 192.168.4.79 22 (telnet from 2.6.18 to 2.6.17 based one)
> and get very slow response, here is related tcpdump output:
> 
> 15:15:47.396925 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x21), length 84
> 15:15:47.397391 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x18), length 84
> 15:15:47.397025 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x22), length 84
> 15:15:47.404166 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 2541002438:2541002458(20) ack 1601271418 win 91 
> 15:15:48.279375 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 0:20(20) ack 1 win 91 
> 15:15:50.031487 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 0:20(20) ack 1 win 91 
> 15:15:53.535710 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 0:20(20) ack 1 win 91 
> 15:16:00.544154 IP 192.168.4.79.ssh > 192.168.4.78.47256: P 0:20(20) ack 1 win 91 
> 15:16:14.561064 IP 192.168.4.79 > 192.168.4.78: ESP(spi=0x0961a360,seq=0x19), length 100
> 15:16:14.561218 IP 192.168.4.78 > 192.168.4.79: ESP(spi=0x027181f9,seq=0x23), length 84

Here is setkey script used to setup communication:
#!/sbin/setkey -f
flush;
spdflush;

spdadd 192.168.4.79 192.168.4.78 any -P out ipsec
        esp/transport//require;

spdadd 192.168.4.78 192.168.4.79 any -P in ipsec
        esp/transport//require;

It has reverted addresses on second machine.

-- 
	Evgeniy Polyakov
