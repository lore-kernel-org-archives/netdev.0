From: Ville Herva <vherva@v.iki.fi>
Subject: 2.6.17-rc1: ping: sendmsg: No buffer space available
Date: Fri, 5 May 2006 09:39:50 +0300
Message-ID: <20060505063950.GA6538@v.iki.fi>
References: <20050606224729.B12034@flint.arm.linux.org.uk>
Reply-To: Ville Herva <Ville.Herva@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from babbage.pp.saunalahti.fi ([62.142.244.116]:21007 "HELO v.iki.fi")
	by vger.kernel.org with SMTP id S1751493AbWEEGju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 02:39:50 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050606224729.B12034@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't know if 
http://bugzilla.kernel.org/show_bug.cgi?id=4615
has been solved yet, but I'm seeing a similar thing with 2.6.17-rc1 and a ppp
connection over ssh.

Earlier kernels (at least linux-2.6.14-rc4) did not show this with the
exactly same settings.

How it happens: 
 - open up the ppp connection over ssh.
 - stress it a bit with samba
 - after a few minutes, pinging the remote end gives
     ping: sendmsg: No buffer space available
   and I have to re-establish the connection

The ssh connection seems solid afaict. Also, with bare ssh connetion, no
problems occur even under load. The ppp connection seems prone to hang
especially with SMB traffic (don't know why.)

In dmesg, there seems to be nothing relevant. /proc/slabinfo doesn't seem to
to have anything alerting in it.

The underlying connection is ADSL (8/1Mbit). The driver is eepro100. ppp is
ppp-2.4.3-6.2.1. 

ppp_deflate is in use:

ppp_deflate             5536  3 
zlib_deflate           18360  1 ppp_deflate
bsd_comp                5312  0 
ppp_async               9664  2 
crc_ccitt               1952  1 ppp_async
ppp_generic            20468  11 ppp_deflate,bsd_comp,ppp_async


