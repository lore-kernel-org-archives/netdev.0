From: Daniel Gryniewicz <dang@fprintf.net>
Subject: RE: [2.4 PATCH] bugfix: ARP respond on all devices
Date: 19 Aug 2003 14:30:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061317825.3744.7.camel@athena.fprintf.net>
References: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>
	 <1061296544.30566.8.camel@dhcp23.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Richard Underwood <richard@aspectgroup.co.uk>,
   "'David S. Miller'" <davem@redhat.com>,
   Stephan von Krawczynski <skraw@ithnet.com>, willy@w.ods.org,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, Marcelo Tosatti <marcelo@conectiva.com.br>,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1061296544.30566.8.camel@dhcp23.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-08-19 at 08:35, Alan Cox wrote:
> You increase it and you shortcut on shared lans. Thats really a seperate
> issue to the question of which source is used. If you loopback someone
> elses address on your own lo device I'm not suprised weird shit happens,
> put the alias on eth0 where it belongs.

Only if you are on a shared lan.  If you are not on a shared lan, then
it will *ONLY* work if linux is on the other end.  No other system will
work.  And, you don't need an alias on loopback.  Merely changing the
default route will result in this.  Change default route from gw 1.1.1.1
on eth0 to gw 2.2.2.2 on eth1 (making sure that 2.2.2.2 doesn't have an
arp entry), and linux will say, on eth1:
whohas 2.2.2.2 tell 1.1.1.2
where 1.1.1.2 is the address on eth0.  No one will respond to this, so
all communication from beyond a directly connected network will now
fail.

-- 
Daniel Gryniewicz <dang@fprintf.net>
