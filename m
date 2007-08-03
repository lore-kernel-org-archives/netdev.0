From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Fri, 3 Aug 2007 12:25:17 +0400
Message-ID: <20070803082517.GB25582@2ka.mipt.ru>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv> <20070802095550.GA27226@2ka.mipt.ru> <20070802101655.GA14749@2ka.mipt.ru> <36758.simon.1186054739@5ec7c279.invalid> <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv> <48738.simon.1186056932@5ec7c279.invalid> <46B21148.2090004@simon.arlott.org.uk> <20070802180842.GA6864@2ka.mipt.ru> <46B2293B.3020406@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39555 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090AbXHCIZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 04:25:41 -0400
Content-Disposition: inline
In-Reply-To: <46B2293B.3020406@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 07:58:03PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
> 19:24:32.897071 IP 192.168.7.4.50000 > 192.168.7.8.2500: S 705362199:705362199(0) win 1500
> 19:24:32.897211 IP 192.168.7.8.2500 > 192.168.7.4.50000: S 4159455228:4159455228(0) ack 705362200 win 14360 <mss 7180>
> 19:24:32.920784 IP 192.168.7.4.50000 > 192.168.7.8.2500: . ack 1 win 1500
> 19:24:32.921732 IP 192.168.7.4.50000 > 192.168.7.8.2500: P 1:17(16) ack 1 win 1500
> 19:24:32.921795 IP 192.168.7.8.2500 > 192.168.7.4.50000: . ack 17 win 14360
> 19:24:32.922881 IP 192.168.7.4.50000 > 192.168.7.8.2500: R 705362216:705362216(0) win 1500
> 19:24:34.927717 IP 192.168.7.8.2500 > 192.168.7.4.50000: R 1:1(0) ack 17 win 14360
> 
> According to RFC 793, the RST from .4 means that the connection 
> is CLOSED.

RFC 2525 - common tcp problems, says we should send RST in this case,
although it does not specify should we send it if socket is in CLOSED
state or not. Well, we send :)
Even if tcp_send_active_reset() will check if socket is in CLOSED state
and will not send data, but is still there, it will not be easily
triggered though, but it can be possible.

-- 
	Evgeniy Polyakov
