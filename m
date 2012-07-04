From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netem: fix rate extension and drop accounting
Date: Wed, 04 Jul 2012 19:23:21 +0200
Message-ID: <1341422601.2583.2393.camel@edumazet-glaptop>
References: <1341307524.2583.115.camel@edumazet-glaptop>
	 <1341309257.2583.153.camel@edumazet-glaptop>
	 <20120703220442.GC5064@nuttenaction>
	 <1341381488.2583.1395.camel@edumazet-glaptop>
	 <20120704165132.GA3455@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Mark Gordon <msg@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64997 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab2GDRXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 13:23:25 -0400
Received: by eaak11 with SMTP id k11so2985267eaa.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 10:23:24 -0700 (PDT)
In-Reply-To: <20120704165132.GA3455@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-04 at 18:51 +0200, Hagen Paul Pfeifer wrote:
> OK, I will work on it tomorrow! But Eric, keep in mind that this accumulative
> behavior is intended: think about a hypothetical satellite link with a
> bandwidth (rate) of 1000 byte/s. If you send three 1000 byte consecutively
> packets. The first packet is delayed for 1 second, the second then is
> transmitted after 2 seconds, the third after three seconds and so on. So
> _this_ accumulative behavior is correct. Anyway, I will look at this tomorrow!
> 

I fear you did your tests with no delay on netem.

Try to setup a rate of 100kbit and a delay of 100ms and to really get
full bandwith (100kbit), I am afraid it doesnt work.

Your algo is OK only if no packets are in queue (obviously)

But if you have 2 or 3 packets, the delay are cumulative,
but the delay should be a fixed bias for each packet.


> Thanks Eric!
> 
> PS: one last question: what do you want to test? TBF and netem rate at the
> same time looks, mmhh, special ... ;-) I ask myself what link exhibit this
> characteristic?

TBF as a netem child was the usual way to have delay + rate before your
patch ?

Not sure why you find it special ?
