From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Thu, 2 Aug 2007 14:16:55 +0400
Message-ID: <20070802101655.GA14749@2ka.mipt.ru>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv> <20070802095550.GA27226@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: john@screen.lv
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55318 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753415AbXHBKRV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 06:17:21 -0400
Content-Disposition: inline
In-Reply-To: <20070802095550.GA27226@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 01:55:50PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Thu, Aug 02, 2007 at 09:19:06AM +0300, john@screen.lv (john@screen.lv) wrote:
> > 1186035057.207629    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [SYN]
> > Seq=0 Len=0
> > 1186035057.207632    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [SYN, ACK]
> > Seq=0 Ack=1 Win=32792 Len=0 MSS=16396
> > 1186035057.207666    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [ACK]
> > Seq=1 Ack=1 Win=1500 Len=0
> > 1186035057.207699    127.0.0.1 -> 127.0.0.1    SMTP Command: EHLO localhost
> > 1186035057.207718    127.0.0.1 -> 127.0.0.1    TCP smtp > 50000 [ACK]
> > Seq=1 Ack=17 Win=32792 Len=0
> > 1186035057.207736    127.0.0.1 -> 127.0.0.1    TCP 50000 > smtp [RST]
> > Seq=17 Len=0
> > 1186035057.223934    127.0.0.1 -> 127.0.0.1    TCP 33787 > 50000 [RST,
> > ACK] Seq=0 Ack=0 Win=32792 Len=0
> > 
> > Can someone please comment as to why, tcp  stack sends rst packet from the
> > wrong source port in this situation.
> 
> Besides the fact, that test applications do not run if started not as
> root, I got this:

And it actually does not initializes a session, since tird line below
shows RST, but not ack. The same with sendmail smtp server (i.e. 25 port
like in your server) and unmodified client.
Please provide application which can trigger the issue and I will help
to debug this issue. If it will help you to debug client, I can run
tcpdump on public server (say 194.85.82.65, please tell me your source 
address) to collect dumps. Current code does not trigger the issue on my
machines (and works not like was intended by you). Ugh, and code really
looks horrible...

-- 
	Evgeniy Polyakov
