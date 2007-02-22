From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Linux 2.6 HTB does only work with existing connections
Date: 22 Feb 2007 14:47:38 +0100
Message-ID: <p73lkiqcnid.fsf@bingen.suse.de>
References: <01e001c7562e$9d452ff0$d7cf8fd0$@com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: "Hua Zhong" <hzhong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:42880 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946009AbXBVMrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 07:47:43 -0500
In-Reply-To: <01e001c7562e$9d452ff0$d7cf8fd0$@com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Hua Zhong" <hzhong@gmail.com> writes:

> Correction: it's TSO, not TOE.
> 
> By googling I found that specifying a big MTU (like 16500) on the "tc class"
> command avoids the "giant" packets. No idea where they come from.

They come from TCP because it will pass down a max MTU sized packet
(upto 64k) for the NIC to segment (Tcp Segmentation Offload)

But the traffic control cannot work with such large packets.

> Any better idea on a proper fix?

Hmm, that's nasty.   The only workaround I could think of would
be to force TSO/LSO off when a non standard queueing discipline is active.

-Andi
