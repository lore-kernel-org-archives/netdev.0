From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next-2.6 03/16] e1000e: do not wakeup Tx queue until ready
Date: Tue, 8 Feb 2011 12:52:56 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A90017BADD014@orsmsx509.amr.corp.intel.com>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1297168167-15755-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110208.122115.183054158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30690 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932065Ab1BHUxA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 15:53:00 -0500
In-Reply-To: <20110208.122115.183054158.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Tuesday, February 08, 2011 12:21 PM
>To: Kirsher, Jeffrey T
>Cc: Allan, Bruce W; netdev@vger.kernel.org; gospo@redhat.com;
>bphilips@novell.com
>Subject: Re: [net-next-2.6 03/16] e1000e: do not wakeup Tx queue until ready
>
>You should not control the TX queue based upon link status information.
>That's the job of netif_carrier_{on,off}().
>
>The TX queue state should be set based solely upon that state of the
>TX ring, whether it is full or not.
>
>When the netif carrier is off, the packet scheduler is blocked from
>sending packets to the driver.
>
>If that isn't happening, that's a bug which you need to track down.
>Maybe you're not doing netif_carrier_off() early enough.

That's what I understood, but the driver was still getting packets
scheduled, at least that's what appeared to happen.  I'll dig deeper.

Thanks,
Bruce.
