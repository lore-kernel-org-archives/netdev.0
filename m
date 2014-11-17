From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Mon, 17 Nov 2014 08:45:17 -0800
Message-ID: <1416242717.5102.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <FC41C24E35F18A40888AACA1A36F3E418AD8F543@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kong, Serey" <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34742 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbaKQQpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 11:45:13 -0500
Received: by mail-ie0-f175.google.com with SMTP id at20so6916141iec.34
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 08:45:12 -0800 (PST)
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AD8F543@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-17 at 16:04 +0000, Nelson, Shannon wrote:

> This typically hits when there are many little TSO packets in a single
> MTU size frame.  The hardware doesn't like dealing with more than 8
> separate buffers.
> 
> If skb_linearize() fails and we try to send the skb as is, the
> hardware will throw an MDD event and disable that particular queue,
> possibly causing a Tx hang, which will lead to a PF reset and then we
> continue on.  It's a bit of a hit to throughput, and most folks get a
> little annoyed when seeing the Tx hang stack trace in their log, but
> it generally isn't fatal.
> 
> If we disable the MDD detection, the hardware ends up putting garbage
> on the wire.
> 
> It looks to me that the way for skb_linearize() to fail is with
> -ENOMEM, in which case we probably have other issues.
> 
This kind of events happens in real workloads, trust me.

> If there are some alternative suggestions for dealing with this, we'd
> be happy to hear about them.

Nelson, all you have to do is to check skb_linearize(skb) return code.

If its a failure, then drop this packet. How hard is this ?

This should hardly trigger in normal conditions.

If some customer complains, then you might implement something more
complex in the future.

Lets fix the bug first in a 100%  safe way.
