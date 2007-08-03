From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: strange tcp behavior
Date: Fri, 03 Aug 2007 19:29:58 +0100
Message-ID: <46B37426.20500@simon.arlott.org.uk>
References: <48738.simon.1186056932@5ec7c279.invalid> <46B21148.2090004@simon.arlott.org.uk> <20070802180842.GA6864@2ka.mipt.ru> <46B2293B.3020406@simon.arlott.org.uk> <20070803082517.GB25582@2ka.mipt.ru> <46956.simon.1186140106@5ec7c279.invalid> <20070803115624.GD5727@2ka.mipt.ru> <60580.simon.1186142626@5ec7c279.invalid> <20070803120920.GA23166@2ka.mipt.ru> <46B35D1E.9050501@simon.arlott.org.uk> <20070803173906.GA30688@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:33616 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679AbXHCSaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 14:30:01 -0400
In-Reply-To: <20070803173906.GA30688@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/08/07 18:39, Evgeniy Polyakov wrote:
> On Fri, Aug 03, 2007 at 05:51:42PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
> 
>> 17:38:03.533589 IP 192.168.7.4.50550 > 192.168.7.8.2500: R 82517592:82517592(0) win 1500 (raw)
>> vs
>> 17:37:38.383085 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 4259643274:4259643274(0) ack 1171836829 win 14360
>> What happened there ?

Erm... you seem to have removed parts of my message in a way that doesn't 
make sense...

On Fri, Aug 03, 2007 at 05:51:42PM +0100, Simon Arlott wrote:
> 17:38:04.536277 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 1:1(0) ack 17 win 14360
> vs
> 17:37:38.383085 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 4259643274:4259643274(0) ack 1171836829 win 14360
> What happened there ?

The first one is the RST sent when the connection is close()d without 
reading, and the second one is the same RST but after other connection 
has been made on the same ports using a different socket.

> It is the same situation, which would happen if you will spam remote
> side with RST packets with arbitrary sequence number in hope that it
> will reset some connection.

Isn't it still possible that the connection that got reset is left open 
(possibly for days) until another connection using the same ports is 
using roughly the same sequence numbers?

-- 
Simon Arlott
