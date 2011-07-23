From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: loopback interface - why checksum on header?
Date: Sat, 23 Jul 2011 09:40:23 -0700
Message-ID: <20110723094023.7c0e91f3@nehalam.ftrdhcpuser.net>
References: <4E2AF71A.6080703@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pierre Louis Aublin <pierre-louis.aublin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53317 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753071Ab1GWQkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2011 12:40:17 -0400
In-Reply-To: <4E2AF71A.6080703@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Jul 2011 18:30:18 +0200
Pierre Louis Aublin <pierre-louis.aublin@inria.fr> wrote:

> Hello everybody
> 
> I am wondering why the checksum of packets sent through the loopback 
> interface is computed on the header only.
> If I understand correctly, it is assumed that a message cannot be 
> corrupted in RAM, thus there is no need to verify the integrity of the 
> whole message.
> However, in that case, there is also no need to compute it on the header.
> Consequently, why is it not the case?
> 
> Thank you in advance
> Pierre Louis Aublin

Linux doesn't bother worrying about the cost of IPv4 header checksum.
The expense of checksumming is the overhead of taking the cache miss
to read the data. Since the header is going to be read anyway, doing
the checksum is equivalent to prefetching the header.
