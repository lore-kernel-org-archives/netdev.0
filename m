From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Who's allowed to set a skb destructor?
Date: Thu, 5 Jul 2007 16:28:47 +0400
Message-ID: <20070705122847.GA13368@2ka.mipt.ru>
References: <p733b032mec.fsf@bingen.suse.de> <20070705122849.GA4759@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andi Kleen <andi@firstfloor.org>,
	Brice Goglin <Brice.Goglin@ens-lyon.org>,
	netdev@vger.kernel.org, Divy Le Ray <divy@chelsio.com>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37136 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757857AbXGEM3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 08:29:01 -0400
Content-Disposition: inline
In-Reply-To: <20070705122849.GA4759@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Jarek.

On Thu, Jul 05, 2007 at 02:28:50PM +0200, Jarek Poplawski (jarkao2@o2.pl) wrote:
> I wonder if it's very unsound to think about a one way list
> of destructors. Of course, not owners could only clean their
> private allocations. Woudn't this save some skb clonning,
> copying or adding new fields for private infos?

There should not be any additional allocations, since they are very
slow, that part of mbuf is really horrible for performance - openbsd
hackers removed additional allocation of mbuf tag in PF code during the
last hackathon, which doubled its performance, that is why skb has only 
one control structure and data area, which incorporates additional 
control information, thus there is no need for multiple destructors.

> Regards,
> Jarek P.

-- 
	Evgeniy Polyakov
