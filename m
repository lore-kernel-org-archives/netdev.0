From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Sat, 4 Aug 2007 20:03:24 +0400
Message-ID: <20070804160324.GB3194@2ka.mipt.ru>
References: <20070802180842.GA6864@2ka.mipt.ru> <46B2293B.3020406@simon.arlott.org.uk> <20070803082517.GB25582@2ka.mipt.ru> <46956.simon.1186140106@5ec7c279.invalid> <20070803115624.GD5727@2ka.mipt.ru> <60580.simon.1186142626@5ec7c279.invalid> <20070803120920.GA23166@2ka.mipt.ru> <46B35D1E.9050501@simon.arlott.org.uk> <20070803173906.GA30688@2ka.mipt.ru> <46B37426.20500@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58722 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbXHDQJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2007 12:09:18 -0400
Content-Disposition: inline
In-Reply-To: <46B37426.20500@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 03, 2007 at 07:29:58PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
> On 03/08/07 18:39, Evgeniy Polyakov wrote:
> > On Fri, Aug 03, 2007 at 05:51:42PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
> > 
> >> 17:38:03.533589 IP 192.168.7.4.50550 > 192.168.7.8.2500: R 82517592:82517592(0) win 1500 (raw)
> >> vs
> >> 17:37:38.383085 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 4259643274:4259643274(0) ack 1171836829 win 14360
> >> What happened there ?
> 
> Erm... you seem to have removed parts of my message in a way that doesn't 
> make sense...

Sorry, I left line I tought were enough to understand your point.

> On Fri, Aug 03, 2007 at 05:51:42PM +0100, Simon Arlott wrote:
> > 17:38:04.536277 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 1:1(0) ack 17 win 14360
> > vs
> > 17:37:38.383085 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 4259643274:4259643274(0) ack 1171836829 win 14360
> > What happened there ?
> 
> The first one is the RST sent when the connection is close()d without 
> reading, and the second one is the same RST but after other connection 
> has been made on the same ports using a different socket.

I understood it, and your question is about possibility for those
numbers to be roughly the same. Answer is 'no', it is not possible
(possible, but with extremely low probability).
If it is - this is a bug in ISN generation algo and must be fixed.

> > It is the same situation, which would happen if you will spam remote
> > side with RST packets with arbitrary sequence number in hope that it
> > will reset some connection.
> 
> Isn't it still possible that the connection that got reset is left open 
> (possibly for days) until another connection using the same ports is 
> using roughly the same sequence numbers?

Of course it is possible, but it very unlikely. Practically it is
impossible in modern OSes - ISN generation algos are designed to prevent
this from happening.

> -- 
> Simon Arlott

-- 
	Evgeniy Polyakov
