From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with fragmented packets on tun/tap interface
Date: Wed, 19 Aug 2015 07:31:13 -0700
Message-ID: <1439994673.6610.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAPBAu3WwLLAYtRuxrA2uDF7J5-1FPfvJ-JVB1_WHNZdf1W_M=A@mail.gmail.com>
	 <1438329395.2748.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPBAu3V2Y56wnfgh1Y9gJ8XxVGEjZYaCXBNfg-uUOeYLy9NTrw@mail.gmail.com>
	 <1438341695.2748.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPBAu3VHtt5TDpvVNUkkQey2fjEYaDDSX8fwzwomyANtUhGQEg@mail.gmail.com>
	 <1439475502.7960.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPBAu3W0xb9xffmgCMGgBPRN5xBc0D6E0GFhVNYXsLida+_WoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Prashant Upadhyaya <praupadhyaya@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35399 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191AbbHSObQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 10:31:16 -0400
Received: by pacgr6 with SMTP id gr6so4450139pac.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 07:31:16 -0700 (PDT)
In-Reply-To: <CAPBAu3W0xb9xffmgCMGgBPRN5xBc0D6E0GFhVNYXsLida+_WoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-19 at 15:44 +0530, Prashant Upadhyaya wrote:


> Hi Eric,
> 
> For some reason, the dropping in the raw table does not work for me
> for the usecase, though I recognize that the raw table operations
> theory, when matched with my usecase theory, is the apparent solution.
> 
> I think the reason is that I use packet sockets with defrag option on
> so that it can select the right queue for load balancing purposes.
> 
> Anyway, not disappointed with the above, I stuck to my theory and
> tried a simple approach. To tie-break the reassembly/defrag done by
> the kernel from the packets from the eth0 and the packets submitted
> from tap (via application), I made a small change in the application.
> I detected that the packets are fragmented in the app, and bumped up
> the 'Identification' field in the IP header and re-checksummed the IP
> header and then submitted it to tap. Since reassembly/defrag is done
> on the basis of srcip, destip, protocol and Identification field
> tupple from IP header, I expected it to work and it does !
> 
> So there we are, I have a nice little solution in place which suits me.

Another idea would have to put your tap device and ethernet device in
different namespaces, as the defrag unit is namespace aware.

Looks like eth0 could be put in a completely new namespace as it holds
no IP address ?

ip netns add eth0ns
ip link set eth0 netns eth0ns
