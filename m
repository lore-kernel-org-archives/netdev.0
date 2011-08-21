From: Julian Anastasov <ja@ssi.bg>
Subject: Re: strange routing issue--packets stop getting forwarded for a live
 connection
Date: Sun, 21 Aug 2011 09:35:22 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108210924010.1581@ja.ssi.bg>
References: <4E506A46.6060407@fatooh.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51236 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260Ab1HUG3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Aug 2011 02:29:42 -0400
In-Reply-To: <4E506A46.6060407@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 20 Aug 2011, Corey Hickey wrote:

> Hi,
> 
> Please forgive me for asking a user question on a dev list; does the
> linux-net list no longer exist? Majordomo wouldn't subscribe me and I
> see no recent history in the archives. If there's a better place for
> this question, please tell me. Anyway:
> 
> I have a strange issue where, reliably, certain conditions cause my
> Linux router to stop forwarding packets for a connection.
> 
> ----------------------------------------------------------------------
> 
> This is my setup:
> 
> client      --> linux router          --> vpn --> work desktop
> 198.18.0.3      198.18.0.1    (eth0)              192.168.10.88
>                 192.168.6.230 (tun0)
> 
> All hosts are running Debian Sid with the stock Debian 3.0.0-1-amd64
> kernel. tun0 is set up by openconnect (open-source client for cisco
> anyconnnect), which has been historically reliable for me.
> 
> I noticed this problem happening when I replaced the router with a new
> host. The old host was 32-bit, running Linux 2.6.38, and configured
> identically (I think) with respect to routing and iptables. I didn't
> have a problem then.
> 
> ----------------------------------------------------------------------
> 
> I have seen this problem happen with http, sometimes, but the easiest
> way to reproduce the issue every time is to use SSH with X11 forwarding
> (I have no idea why). I can SSH, through my router and VPN connection,
> to my desktop at work. I can log in, poke around, do whatever; as soon
> as I run some particular X11 programs, the connection hangs. xlogo and
> xeyes are fine, but rxvt and jconsole are not.
> 
> So, my baseline test is to run rxvt directly. This command always hangs:
> 
> $ ssh -X chickey@192.168.10.88 rxvt
> 
> I have run simultaneous tcpdumps on the router: one on eth0 and the
> other on tun0. I see the tcp connection and ssh sessions get set up,
> then many encrypted packets go back and forth. At a certain, reliably
> reproducible point, a 1368 byte packet comes in on eth0 and does not
> leave tun0; the retransmissions do not get forwarded either.
> 
> I have not been able to figure out the cause of this. Here's what I have
> investigated:
> 
> 1. Number of packets on the connection; doesn't seem to matter, because
> I can use SSH for other purposes just fine.
> 
> 2. Transmission rate; doesn't seem to matter, because I can do
> $ ssh -X chickey@192.168.10.88 cat /dev/zero > /dev/null
> 
> 3. MTU size; 1500 on eth0 and 1406 on tun0. Bigger packets have been
> transferred fine.

	Lower MTU, it can be PMTUD problem. At 04:50:24.112658
I see 7801:9169 is 1420 bytes and no ICMP FRAG NEEDED is generated.
May be these two regressions explain it:

http://marc.info/?l=linux-netdev&m=131342172722536&w=2

	There are 2 fixes you can try or more recent kernel
tree, for example 3.1-rc2 has the fixes.

Regards

--
Julian Anastasov <ja@ssi.bg>
