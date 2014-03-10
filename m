From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP reordering and Multiple DL path
Date: Mon, 10 Mar 2014 09:15:08 -0700
Message-ID: <1394468108.3607.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <AB9D0874A51C404B8D86602911E629521A9E0D4D@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Soum, Redouane" <redouane.soum@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:61024 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbaCJQPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 12:15:13 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so7288420pde.11
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 09:15:10 -0700 (PDT)
In-Reply-To: <AB9D0874A51C404B8D86602911E629521A9E0D4D@IRSMSX102.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 15:44 +0000, Soum, Redouane wrote:
> Hi,
> 
> I have several path in DL between an Application Processor and a Modem
> using different network interfaces (USB CDC NCMs) with the same ip
> address (connected to the same network)
> 
> Having several network interfaces used in DL implies to have out of
> order packets, even if the ooo packets will most likely come close
> together.
> 
> Here is my understanding on the impact on TCP throughput :
> 
> -        OOO packets will lead to Dup acks.
> -        When sender receives 3 Dup acks it'll start fast recovery
> which will reduce TCP congestion window.
> 
> First question is my understanding correct ?
> 
> Assuming it is : 
> In order to solve that issue I am thinking to add a small delay before
> sending dup acks for OoO packets.
> The objective is to be sure that dup acks for OoO packets will only be
> sent for OoO packet due to different path in the network, and not
> because of the different network interfaces.
> 
> However I am not sure how complex it would be to implement and which
> part of the TCP stack need to be modified.
> Any advice to solve that issue ?

This is quite complex.

Note that we are working on a more generic solution, involving a high resolution timer,
for not only this case, but more generally :

Delayed ACK (application could tell TCP stack its max latency for RPC)

TSO autodefer bugs (currently we rely on future ACKS, while we should
not)

TCP_CORK_US (extend TCP auto cork with a usec timer)

Trick is to not add uncontrolled jitter on ACKs, otherwise we screw up
delay based CC.
