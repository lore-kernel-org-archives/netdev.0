From: Bill Fink <billfink@mindspring.com>
Subject: Re: Autotuning and send buffer size
Date: Fri, 11 Jul 2008 13:07:03 -0400
Message-ID: <20080711130703.58115c44.billfink@mindspring.com>
References: <20080711150208.GA15305@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:52207 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753357AbYGKRHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 13:07:09 -0400
In-Reply-To: <20080711150208.GA15305@citi.umich.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jul 2008, Jim Rees wrote:

> Bill Fink and others have mentioned that tcp buffer size autotuning can
> cause a 5% or so performance penalty.  I looked into this a bit, and it
> appears that if you set the sender's socket buffer too big, performance
> suffers.
> 
> Consider this, on a 1Gbps link with ~.1msec delay (12KB bdp):
> 
> Fixed 128KB sender socket buffer:
> nuttcp -i1 -w128k pdsi5
>  1115.4375 MB /  10.00 sec =  935.2707 Mbps 4 %TX 11 %RX
> 
> Fixed 8MB sender socket buffer:
> nuttcp -i1 -w8m pdsi5
>  1063.0625 MB /  10.10 sec =  882.7833 Mbps 4 %TX 15 %RX
> 
> Autotuned sender socket buffer:
> nuttcp -i1 pdsi5
>  1056.9375 MB /  10.04 sec =  883.1083 Mbps 4 %TX 15 %RX
> 
> I don't undestand how a "too big" sender buffer can hurt performance.  I
> have not measured what size the sender's buffer is in the autotuning case.
> 
> Yes, I know "nuttcp -w" also sets the receiver's socket buffer size.  I
> tried various upper limits on the receiver's buffer size via
> net.ipv4.tcp_rmem but that doesn't seem to matter as long as it's big
> enough:
> 
> nuttcp -i1 pdsi5
> sender wmem_max=131071, receiver rmem_max=15728640
>  1116.9375 MB /  10.01 sec =  936.4816 Mbps 3 %TX 16 %RX
> sender wmem_max=15728640, receiver rmem_max=15728640
>  1062.8750 MB /  10.10 sec =  882.6013 Mbps 4 %TX 15 %RX
> sender wmem_max=15728640, receiver rmem_max=131071
>  1060.2500 MB /  10.07 sec =  883.2847 Mbps 4 %TX 15 %RX

FYI you can use the nuttcp "-ws" parameter in addition to the "-w"
parameter to independently set the server's socket buffer size to
be different than the client's socket buffer size.  And you can also
specify "-ws0" if you wanted the server (which is the receiver for
the client transmitter case) to autotune while still being able to
explicitly specify the client's socket buffer size with the "-w"
setting.

						-Bill
