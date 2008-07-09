From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TCP checksum error on local device
Date: Wed, 9 Jul 2008 16:38:38 +0100
Message-ID: <20080709153836.GL28029@solarflare.com>
References: <9a6873fa0807090734ge7ef12lf09e78db44ba77f5@mail.gmail.com> <20080709151019.GG27741@nereid> <4874D936.9020100@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kevin Spiteri <kspiteri@ieee.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:48567 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751834AbYGIPin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 11:38:43 -0400
Content-Disposition: inline
In-Reply-To: <4874D936.9020100@ieee.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Spiteri wrote:
[...]
> I saw the behaviour as strange because only the segment containing data 
> had an incorrect TCP checksum, all other segments (SYN, SYN ACK, ACKs 
> without data and FIN ACK) had a correct TCP checksum.
> 
> Also, the incorrect checksum field seems to depend on the IP address and 
> the packet length, but not on the port number, sequence/acknowledgement 
> number or data content. Thus, the incorrect checksum is the same when 
> the sample is run repeatedly, it only changes when the data length 
> and/or IP address are changed.
[...]

The TCP/IP stack will unconditionally start calculating a checksum as it
prepares some of the headers.  Then at a later stage it checks the checksum
capability of the destination route/device (checksum calculation may be
offloaded or unnecessary) and decides whether to update the TCP checksum to
include the rest of the packet, including the payload.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
