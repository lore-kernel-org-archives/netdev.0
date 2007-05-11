From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 08:15:09 -0400
Message-ID: <1178885709.4093.32.camel@localhost>
References: <20070511093202.GB24695@2ka.mipt.ru>
	 <OF6C27DF4E.9060BDB4-ON652572D8.0035C627-652572D8.00363827@in.ibm.com>
	 <20070511095602.GA5762@2ka.mipt.ru> <1178883002.4093.26.camel@localhost>
	 <20070511115352.GA6508@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:14642 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755114AbXEKMPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 08:15:18 -0400
Received: by wx-out-0506.google.com with SMTP id h31so848793wxd
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 05:15:17 -0700 (PDT)
In-Reply-To: <20070511115352.GA6508@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-05 at 15:53 +0400, Evgeniy Polyakov wrote:

> As I said there might be another lock, if interrupt handler is shared,
> or registers are accessed, but it is privite driver's business, which
> has nothing in common with stack itself. 

Ok, we are saying the same thing then. eg in e1000 that would be
tx_ring->lock or something along those lines.

> Stack just queues an skb,
> which, after detached from the tx queue by driver, just does not exist
> for stack anymore. It can be dequeed with rcu protection even.

in my case i had a dev->blist where the stack queued. You really want to
avoid requeueing altogether.
The trick i used is to have the driver tell you how many packets you can
pull off the qdisc.

cheers,
jamal



