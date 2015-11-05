From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: AF_PACKET mmap() v4...
Date: Thu, 5 Nov 2015 07:53:35 +0100
Message-ID: <20151105065335.GB1824@netboy>
References: <20151105.000414.1682124328670738318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34818 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161802AbbKEGyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 01:54:54 -0500
Received: by wmll128 with SMTP id l128so4523462wml.0
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 22:54:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151105.000414.1682124328670738318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 05, 2015 at 12:04:14AM -0500, David Miller wrote:
> So I want everyone to think about whether there are any other changes
> we might want to make given that we have to make a v4 anyways.

One thing I would like to see is a field for a desired transmit time.
Time based scheduling is a new topic, never discussed on this list
before, afaict.  HW already supports this, for example, the Intel i210
card has a high priority queue where you can tell it a Tx time in
terms of the PTP clock.

This functionality is useful in industrial Ethernet protocols.  There
must be a dozen of these out there, and a new IEEE standard is in the
works by Time Sensitive Networking (TSN) group.

I haven't thought too much about how to implement this, but the
eventual goal would be a generic time based scheduler that either uses
special HW features or does best effort in SW.  User space would have
a socket option for desired Tx time, and this should also be available
over the mmap interface.

Thanks,
Richard
