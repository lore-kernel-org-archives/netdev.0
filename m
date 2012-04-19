From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head()
 calls
Date: Thu, 19 Apr 2012 19:25:06 +0200
Message-ID: <1334856306.2395.208.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
	 <1334764184.2472.299.camel@edumazet-glaptop>
	 <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>
	 <1334776707.2472.316.camel@edumazet-glaptop>
	 <1334778707.2472.333.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi>
	 <1334835018.2395.66.camel@edumazet-glaptop>
	 <1334841481.2395.175.camel@edumazet-glaptop>
	 <1334843527.2395.182.camel@edumazet-glaptop>
	 <1334844652.2395.187.camel@edumazet-glaptop>  <4F904955.7070403@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44949 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab2DSRZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 13:25:13 -0400
Received: by eaaq12 with SMTP id q12so2279355eaa.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 10:25:12 -0700 (PDT)
In-Reply-To: <4F904955.7070403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 10:20 -0700, Rick Jones wrote:

> By copying them to smaller buffers? Or just by altering truesize? 
> Wasn't the whole point of fixing all the broken truesize settings to 
> accurately account for memory consumed?

I checked, their truesize are OK (1024+256) for ixgbe driver.
They could be little smaller, but not that much. (512 + 256)

No, its only the sk_rcvbuf is small for a tcp sender,
and sk_add_backlog() makes sure we dont queue more than sk_rcvbuf bytes
in backlog.
