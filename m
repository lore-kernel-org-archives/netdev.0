From: David Miller <davem@davemloft.net>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 06:25:23 -0700 (PDT)
Message-ID: <20090311.062523.230181548.davem@davemloft.net>
References: <20090311082920.GA20543@bts.sk>
	<20090311.014103.163410266.davem@davemloft.net>
	<49B7802E.2070707@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: md@bts.sk, johnwheffner@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753884AbZCKNZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 09:25:37 -0400
In-Reply-To: <49B7802E.2070707@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 11 Mar 2009 10:11:10 +0100

> I am interested to know how use AQM in practice.

You just need RED, no need for ECN or anything like that.

RED will drop randomly when a certain percentage of the backlog queue
is consumed, and then behave like tail-drop after the next
configured threshold is reached.

It prevents TCPs from synchronizing, which is what happens with
pure tail-drop routers.
