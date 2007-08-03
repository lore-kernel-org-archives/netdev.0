From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: Re: strange tcp behavior
Date: Fri, 3 Aug 2007 12:21:46 +0100
Message-ID: <46956.simon.1186140106@5ec7c279.invalid>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv>
    <20070802095550.GA27226@2ka.mipt.ru>
    <20070802101655.GA14749@2ka.mipt.ru>
    <36758.simon.1186054739@5ec7c279.invalid>
    <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv>
    <48738.simon.1186056932@5ec7c279.invalid>
    <46B21148.2090004@simon.arlott.org.uk>
    <20070802180842.GA6864@2ka.mipt.ru>
    <46B2293B.3020406@simon.arlott.org.uk>
    <20070803082517.GB25582@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: john@screen.lv, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:44280 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759582AbXHCLV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 07:21:57 -0400
In-Reply-To: <20070803082517.GB25582@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, August 3, 2007 09:25, Evgeniy Polyakov wrote:
> On Thu, Aug 02, 2007 at 07:58:03PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
>> 19:24:32.897071 IP 192.168.7.4.50000 > 192.168.7.8.2500: S 705362199:705362199(0) win 1500
>> 19:24:32.897211 IP 192.168.7.8.2500 > 192.168.7.4.50000: S 4159455228:4159455228(0) ack 705362200 win
>> 14360 <mss 7180>
>> 19:24:32.920784 IP 192.168.7.4.50000 > 192.168.7.8.2500: . ack 1 win 1500
>> 19:24:32.921732 IP 192.168.7.4.50000 > 192.168.7.8.2500: P 1:17(16) ack 1 win 1500
>> 19:24:32.921795 IP 192.168.7.8.2500 > 192.168.7.4.50000: . ack 17 win 14360
>> 19:24:32.922881 IP 192.168.7.4.50000 > 192.168.7.8.2500: R 705362216:705362216(0) win 1500
>> 19:24:34.927717 IP 192.168.7.8.2500 > 192.168.7.4.50000: R 1:1(0) ack 17 win 14360
>>
>> According to RFC 793, the RST from .4 means that the connection
>> is CLOSED.
>
> RFC 2525 - common tcp problems, says we should send RST in this case,
> although it does not specify should we send it if socket is in CLOSED
> state or not. Well, we send :)
> Even if tcp_send_active_reset() will check if socket is in CLOSED state
> and will not send data, but is still there, it will not be easily
> triggered though, but it can be possible.

Since the connection is considered closed, couldn't another socket re-use it?

Socket A: Recv data (unread)
Socket A: Recv RST
Socket B: Reuses connection (same IPs/ports)
Socket A: Close

Wouldn't that disrupt socket B's use of the connection?

-- 
Simon Arlott
