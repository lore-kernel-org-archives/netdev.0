From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Wed, 08 Nov 2006 10:38:52 -0800
Message-ID: <1163011132.10806.189.camel@localhost.localdomain>
References: <1162924354.10806.172.camel@localhost.localdomain>
	 <1163001318.3138.346.camel@laptopd505.fenrus.org>
	 <20061108162955.GA4364@suse.de>
Reply-To: tim.c.chen@linux.intel.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, davem@sunset.davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:53766 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1161694AbWKHT2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 14:28:21 -0500
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20061108162955.GA4364@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-08 at 17:29 +0100, Olaf Kirch wrote:

> Is it proven that the number of ACKs actually cause bandwidth problems?
> I found Volanomark to exercise the scheduler more than anything else,
> so maybe the slowdown, while triggered by an increased number of ACKs,
> is caused by something else entirely.
> 

The patch in question affects purely TCP and not the scheduler.  I don't
think the scheduler has anything to do with the slowdown seen after
the patch is applied.

The total number of messages being exchanged around the chatrooms in 
Volanomark remain unchanged.  But ACKS increase by 3.5 times and
segments received increase by 38% from netstat.  

ACK is comparable in size to the actual Volanomark messages as 
those are  pretty small (<100 byte).

So I think it is reasonable to conclude that the increase in TCP traffic
reduce the bandwidth and throughput in Volanomark.

However, Volanomark is just a benchmark to alert us to changes.  
If in real applications with small segment, this patch is 
needed to fix congestion window adjustment as Dave pointed 
out, and impact on bandwidth not as important, so be it.

Tim
