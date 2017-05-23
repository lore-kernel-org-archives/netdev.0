From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel
 memory low
Date: Tue, 23 May 2017 11:26:25 -0400 (EDT)
Message-ID: <20170523.112625.33559883707681029.davem@davemloft.net>
References: <04bc5b49-9282-a6ca-2b95-fb8fc9750555@mentor.com>
        <20170522.115426.1239443379414364630.davem@davemloft.net>
        <1495528968.2174.2.camel@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim_baxter@mentor.com, bjorn@mork.no, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36272 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757861AbdEWP01 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:26:27 -0400
In-Reply-To: <1495528968.2174.2.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.com>
Date: Tue, 23 May 2017 10:42:48 +0200

> Am Montag, den 22.05.2017, 11:54 -0400 schrieb David Miller:
>> 
>> Unfortunately without a real notifier of some sort (there isn't one, and
>> it isn't actually easy to come up with a clean way to do this which is
>> probably why it doesn't exist yet in the first place) I really cannot
>> recommend anything better.
>> 
>> That being said, probably for the time being we should just backoff each
>> and every request, always trying initially to do the higher order thing.
> 
> We could use a counter. After the first failure, do it once, after the
> second twice and so on. And reset the counter as a higher order
> allocation works. (just bound it somewhere)

So an exponential backoff, that might work.
