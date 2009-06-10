From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH iproute2 3/2 v2] tc_core: Return double from	tc_core_tick2time()
Date: Wed, 10 Jun 2009 14:25:53 +0200
Message-ID: <4A2FA651.1030207@trash.net>
References: <20090609080536.GD5237@ff.dom.local> <4A2E6BA4.30002@trash.net> <20090609225317.GA3262@ami.dom.local> <4A2EEA84.3080803@trash.net> <20090610074634.GB2673@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Antonio Almeida <vexwek@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57179 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662AbZFJMZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 08:25:53 -0400
In-Reply-To: <20090610074634.GB2673@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Jun 10, 2009 at 01:04:36AM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> Hmm... I'm not sure this floor() is needed here, but maybe I'll get it
>>> tomorrow... 
>> Its not. It was mainly a suggestion to make the symetry more explicit.
>> I hope gcc understands :)
> 
> If so, then maybe let's reconsider previous example:
> 
>> Let's see how it's used (mainly) in tc_calc_xmittime() e.g. for
>> Antonio's mostly 800byte and 555Mbit rate:
>>
>> tc_core_time2tick(TIME_UNITS_PER_SEC * (double)size/rate)
>> tc_core_time2tick(1000000 * (double) 800/69375000)
>> tc_core_time2tick(11.53153)
> 
> Let's say it returns 116 (after x10 with ceil()). Then, going backwards:
> 
> tc_calc_xmitsize()
> {
> 	return ((double) 69375000 * tc_core_tick2time(116)) / TIME_UNITS_PER_SEC;
> }
> 
> would give us: 763 after /10 with floor(), and 804 without floor().
> The latter looks nicer to me but I leave the choice to you or Stephen.

Agreed, I made a thinko somewhere.
