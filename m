From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 18:53:27 -0400
Message-ID: <45413C67.3090105@psc.edu>
References: <20061025110843.0cbd18a7@freekitty> <4540F076.70801@psc.edu> <20061026224407.GA2018@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:1531 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1945962AbWJZWxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 18:53:43 -0400
To: Hagen Paul Pfeifer <hagen@jauu.net>,
	John Heffner <jheffner@psc.edu>,
	Stephen Hemminger <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
In-Reply-To: <20061026224407.GA2018@c3po.0xdef.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hagen Paul Pfeifer wrote:
> * John Heffner | 2006-10-26 13:29:26 [-0400]:
> 
>> My reservation in doing this would be that as an administrator, I may 
>> want to choose exactly what congestion control is available any any 
>> given time.  The different congestion control algorithms are not 
>> necessarily fair to each other.
> 
> ACK, completely right. A user without CAP_NET_ADMIN MUST NOT changed the
> algorithm.  We know that there are some unfairness out there. And maybe some
> time ago someone introduce a satellite-algorithm which is per definition
> completely unfair to vanilla tcp.
> We should guard this with a CAP_NET_ADMIN capability so that built-in modules
> also shouldn't be enabled.

I don't know if I'd want to go that far.  For example, there's a nice 
protocol TCP-LP which is by design unfair in the other direction -- it 
yields to other traffic so that you can basically run a scavenger service.

If you really care about this, you could try to rank protocols based on 
aggressiveness (note this is not trivial) and do something like 'nice' 
where mortals can only nice up not down.  Practically speaking, I'm not 
sure this is necessary (worth the effort).

   -John
