From: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Subject: Re: tc filter mask for ACK packets off?
Date: Tue, 03 Jan 2012 08:31:49 +0100
Message-ID: <21734335.uCtjXOcSpA@alaris>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
Reply-To: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50483 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174Ab2ACHbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 02:31:51 -0500
In-Reply-To: <1325385056.4174.51.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 of December 2011 21:30EN, John A. Sullivan III wrote:
> Hello, all.  I've been noticing that virtually all the documentation
> says we should prioritize ACK only packets and that they can be
> identified with match u8 0x10 0xff.  However, isn't the actual flag
> field only 6 bits longs and the first two belong to a previous 6 bit
> reserved field?

It's even worse, those two bits are in fact used for ECN (RFC 3168).

> If that is true, if ever those bits are set, our filters will
> unnecessarily break.  Shouldn't it be match u8 0x10 0x3f?

I think so.

However, by a "ACK only" packet (worth prioritizing), I would rather 
understand a packet with ACK flag without any payload, not a packet with 
ACK as the only flag. For many TCP connections, all packets except 
initial SYN and SYN-ACK and two FIN packets have ACK as the only flag. 
So my guess is you should rather prioritize all TCP packets with no 
application layer data.

                                                         Michal Kubecek
