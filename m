From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 31 Jan 2005 13:16:45 +0100
Message-ID: <1107173804.5812.133.camel@tsc-6.cph.tpack.net>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
	 <1104895169.1117.63.camel@jzny.localdomain>  <41DC0931.80603@tpack.net>
	 <1105019912.2314.20.camel@jzny.localdomain>
	 <1105023972.3462.48.camel@tsc-6.cph.tpack.net>
	 <1105104757.1046.63.camel@jzny.localdomain>
	 <1105111605.3462.101.camel@tsc-6.cph.tpack.net>
	 <1105363092.1041.146.camel@jzny.localdomain>
	 <1105917038.1091.1041.camel@jzny.localdomain> <41EC3067.6050104@tpack.net>
	 <41FD702D.2060403@tpack.net> <1107130177.7847.96.camel@jzny.localdomain>
	 <41FD7C6F.3010005@tpack.net>  <1107142012.8021.109.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1107142012.8021.109.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 04:26, jamal wrote:
> It does look pretty sane.. Tested?

Nope, I don't have access to any relevant HW. Hopefully someone
else can give it some beating. Please.

A simple test could be:
 o start tcpdump on host B
 o start pinging from host A to B
 o unplug cable on host A
 o wait a while and then plug the cable back in

This is what I get on an embedded PPC:
01:41:27.712729 IP 192.168.6.22 > 192.168.27.119: icmp 64: echo request
seq 7
01:41:28.712697 IP 192.168.6.22 > 192.168.27.119: icmp 64: echo request
seq 8
01:41:43.712240 IP 192.168.6.22 > 192.168.27.119: icmp 64: echo request
seq 23
01:41:44.712210 IP 192.168.6.22 > 192.168.27.119: icmp 64: echo request
seq 24

The interesting point is that the jump in sequence number coincides
with the jump in rx time. Theory is that not all drivers will behave
like this.

Hopefully someone can verify that with e.g. an e1000, and then check
whether the patch I send makes any difference.

-Tommy
