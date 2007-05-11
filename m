From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 07:30:02 -0400
Message-ID: <1178883002.4093.26.camel@localhost>
References: <20070511093202.GB24695@2ka.mipt.ru>
	 <OF6C27DF4E.9060BDB4-ON652572D8.0035C627-652572D8.00363827@in.ibm.com>
	 <20070511095602.GA5762@2ka.mipt.ru>
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
Received: from wx-out-0506.google.com ([66.249.82.224]:56299 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756147AbXEKLaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 07:30:06 -0400
Received: by wx-out-0506.google.com with SMTP id h31so838208wxd
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 04:30:05 -0700 (PDT)
In-Reply-To: <20070511095602.GA5762@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-05 at 13:56 +0400, Evgeniy Polyakov wrote:

> I meant no locks during processing of the packets (pci read/write, dma
> setup and so on), of course it is needed to dequeue a packet, but only
> for that operation.

I dont think you can avoid the lock Evgeniy. You need to protect against
the tx ring having some other things happening to it from the napi poll
or netdev interupts (most of the drivers touch the tx ring on the napi
poll).

cheers,
jamal

