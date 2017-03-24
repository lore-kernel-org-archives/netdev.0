From: Jiri Benc <jbenc@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Fri, 24 Mar 2017 10:55:48 +0100
Message-ID: <20170324105549.34b3e778@griffin>
References: <20170207140144.GA11233@localhost>
        <20170209080242.GA1698@localhost.localdomain>
        <20170209110941.GA1449@localhost>
        <20170323162145.GB8192@localhost>
        <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miroslav Lichvar <mlichvar@redhat.com>,
        Richard Cochran <richardcochran@gmail.com>,
        netdev@vger.kernel.org,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Denny Page <dennypage@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45472 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751567AbdCXJzx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 05:55:53 -0400
In-Reply-To: <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Mar 2017 10:08:00 -0700, Denny Page wrote:
> I am very surprised at this. The application caching approach
> requires the application retrieve the value via a system call. The
> system call overhead is huge in comparison to everything else. More
> importantly, the application cached value may be wrong. If the
> application takes a sample every 5 seconds, there are 5 seconds of
> timestamps that can be wildly wrong.

You can add a netlink event that is sent on speed change. No need for
polling then and the wrong timestamp window will be very tiny. (It
can't be zero, even with per-packet data.)

ethtool needs to be converted to netlink, anyway.

 Jiri
