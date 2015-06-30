From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] vxlan: GRO support at tunnel layer
Date: Tue, 30 Jun 2015 07:06:34 +0200
Message-ID: <1435640794.4110.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435360189-641007-1-git-send-email-tom@herbertland.com>
	 <558DF24A.1040504@hp.com>
	 <df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com>
	 <5591A4DF.4010104@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>,
	Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33467 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbbF3FGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 01:06:39 -0400
Received: by wiwl6 with SMTP id l6so119195736wiw.0
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 22:06:37 -0700 (PDT)
In-Reply-To: <5591A4DF.4010104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-29 at 13:04 -0700, Rick Jones wrote:

> PS  FWIW, if I shift from using just the linux native vxlan to a "mostly 
> full" set of OpenStack compute node plumbing - two OVS bridges and a 
> linux bridge and associated plumbing with a vxlan tunnel defined in OVS, 
> but nothing above the Linux bridge (and no VMs) I see more like 4.9 
> Gbit/s.  The veth pair connecting the linux bridge to the top ovs bridge 
> show rx checksum and gro enabled.  the linux bridge itself shows GRO but 
> rx checksum off (fixed).  I'm not sure how to go about checking the OVS 
> constructs.
> 

This is exactly why we had to implement GRO at the first stage.

We can not assume a proper netdev tunnel is there where we can use
gro_cells.
