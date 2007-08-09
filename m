From: Unai Uribarri <unai.uribarri@optenet.com>
Subject: Re: [PATCH 1/1] af_packet: don't enable timestamps in mmap'ed
	sockets
Date: Thu, 09 Aug 2007 20:13:54 +0200
Message-ID: <1186683234.24669.65.camel@localhost.localdomain>
References: <1186669314.24669.56.camel@localhost.localdomain>
	 <20070809143322.GA5345@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-mad.optenet.com ([213.27.232.70]:39573 "EHLO
	mta-mad.optenet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbXHISN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 14:13:58 -0400
In-Reply-To: <20070809143322.GA5345@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On jue, 2007-08-09 at 18:33 +0400, Evgeniy Polyakov wrote:
> On Thu, Aug 09, 2007 at 04:21:54PM +0200, Unai Uribarri (unai.uribarri@optenet.com) wrote:
> > The attached patch removes the automatic timestamp activation, that
> > only mmap'ed AF_PACKET sockets perform. I known it can break user
> > applications, but I believe that it's the correct solution.
> 
> How tcpdump with mmap libpcap will work with it?

In Linux, you can enable timestamps on any socket executing:

int val = 1;
setsockopt(sock, SOL_SOCKET, SO_TIMESTAMP, &val, sizeof(val));

PD: Current release of tcpdump doesn't mmap the reception ring and
timestamps packets at user space with gettimeofday. It isn't the best
performing alternative, but it's portable.



