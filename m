From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Tue, 22 Apr 2008 20:59:45 -0700 (PDT)
Message-ID: <20080422.205945.229828014.davem@davemloft.net>
References: <480E8523.4030007@hp.com>
	<1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752061AbYDWD7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 23:59:44 -0400
In-Reply-To: <1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John Heffner" <johnwheffner@gmail.com>
Date: Tue, 22 Apr 2008 19:17:39 -0700

> On Tue, Apr 22, 2008 at 5:38 PM, Rick Jones <rick.jones2@hp.com> wrote:
> >  oslowest:~# netstat -an | grep ESTAB
> >  ...
> >  tcp    0 2760560 10.208.0.1:40500    10.208.0.45:42049   ESTABLISHED
> >  ...
> >
> >  Is this expected behaviour?
> 
> What is your interface txqueuelen and mtu?  If you have a very large
> interface queue, TCP will happily fill it up unless you are using a
> delay-based congestion controller.

Yes, that's the fundamental problem with loss based congestion
control.  If there are any queues in the path, TCP will fill them up.

Vegas and other similar techniques are able to avoid this, but come
with the fundamental flaw that it's easy to get them into situations
where they do not respond to increases in pipe space adequately, and
thus underperform compared to loss based algorithms.
