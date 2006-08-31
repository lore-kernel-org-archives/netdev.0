From: Alexander Vodomerov <alex@sectorb.msk.ru>
Subject: Re: high latency with TCP connections
Date: Thu, 31 Aug 2006 12:14:44 +0400
Message-ID: <20060831081443.GA27075@isil.ipib.msu.ru>
References: <20060830100734.GA22235@isil.ipib.msu.ru> <20060830102727.11e11453@localhost.localdomain> <20060830.143955.55510936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from isil.ipib.msu.ru ([212.192.237.15]:9708 "EHLO isil.ipib.msu.ru")
	by vger.kernel.org with ESMTP id S1751288AbWHaIOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 04:14:51 -0400
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060830.143955.55510936.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2006 at 02:39:55PM -0700, David Miller wrote:
> > Expecting any performance with one byte write's is silly.
> 
> This is absolutely true.  TCP_NODELAY can only save you when you are
> sending a small amount of data "in aggregate", such as in an SSH or
> telnet session, whereas in the case being shown here a large amount of
> data is being sent in small chunks which will always get bad
> performance.

Information is sent with one byte write's because it is not available at
the moment of sending (it may be read from hardware device or user). If
I change 1 to 10 or 100 nothing changes. I'm afraid there is a bit of
misunderstanding here. Only very small amount of data is being sent over
network. The total traffic for example I sent is only 10 bytes/s. After
every 10th packet program does usleep(100000) to simulate pause before
next available data.

There are really 3 factors:
1) total size of information is small
2) data for transferring is arrived by small portions from external
source
3) it is very important that any portion should be delivered to receiver
as soon as possible.
Is TCP is good choice for such transfer or some other protocol is better
suited?

With best regards,
   Alexander.
