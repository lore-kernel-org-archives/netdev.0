From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: delayed ack timer, slow start and LRO
Date: Wed, 23 Jul 2008 02:11:47 +0400
Message-ID: <20080722221147.GA29276@2ka.mipt.ru>
References: <488654A5.5040905@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jean-pascal billaud <billaud@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:33399 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756062AbYGVWLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 18:11:48 -0400
Content-Disposition: inline
In-Reply-To: <488654A5.5040905@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Jul 22, 2008 at 02:44:05PM -0700, jean-pascal billaud (billaud@vmware.com) wrote:
> Also as LRO adds some latency, it seems possible to me that the sender 
> retransmission timer will expires before the delayed ack timer expires. In 
> this case, how is this gonna work ? Is it possible that the sender will 
> stay stuck in
> its slow start trying to retransmit endlessly the same n packets ?

You can check how your favourite driver handles lro and calls
lro_flush_all(), lro also aggregate packets upto predefined limits of
total size and numbr of 'inner' packets. It also self-destructs when
flow breaks (retransmit, pure ack and so on).

-- 
	Evgeniy Polyakov
