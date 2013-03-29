From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next PATCH] [RFC] [v2] net: add option to enable error
 queue packets waking select
Date: Fri, 29 Mar 2013 08:20:04 +0100
Message-ID: <20130329072004.GA2463@netboy.at.omicron.at>
References: <20130328211925.7644.15781.stgit@jekeller-hub.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50055 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755815Ab3C2HUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 03:20:16 -0400
Received: by mail-ee0-f46.google.com with SMTP id e49so95290eek.19
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 00:20:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130328211925.7644.15781.stgit@jekeller-hub.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 02:19:25PM -0700, Jacob Keller wrote:
> Currently, when a socket receives something on the error queue it only wakes up
> the socket on select if it is in the "read" list, that is the socket has
> something to read. It is useful also to wake the socket if it is in the error
> list, which would enable software to wait on error queue packets without waking
> up for regular data on the socket. The main use case is for receiving
> timestamped transmit packets which return the timestamp to the socket via the
> error queue. This enables an application to select on the socket for the error
> queue only instead of for the regular traffic.

I would fully support having this kind of ability. As it stands now,
the SO_TIMESTAMPING interface makes it very inconvenient for the
application to obtain transmit time stamps.

As a concrete example, take the ptp4l [1] program. After sending a
packet for which a time stamp is expected, we call recvmsg() on the
MSG_ERRQUEUE repeatedly, but give up after a certain number of
tries. The repetitions are needed because the driver may delay the
time stamped packet for quite some time, and the giving up is required
because it is possible for time stamps to be lost or dropped.

Having the ability to poll/select the error queue would open more
attractive possibilities for applications. Instead of a cheesy retry
loop, just poll/select the error queue with a reasonable timeout
value.

Thanks,
Richard

1. http://linuxptp.sourceforge.net/
   file: sk.c
   line: 199
   function: sk_receive()
