From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Thu, 23 Mar 2017 20:07:33 +0100
Message-ID: <20170323190733.GA30056@localhost.localdomain>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
 <20170323162145.GB8192@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38905 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754236AbdCWTHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 15:07:44 -0400
Received: by mail-wm0-f47.google.com with SMTP id t189so4411597wmt.1
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 12:07:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170323162145.GB8192@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 05:21:45PM +0100, Miroslav Lichvar wrote:
> A better approach might be a control message that would provide the
> original interface index together with the length of the packet, so
> the application could transpose the HW timestamp and map the HW
> interface to the PHC.

This sounds better than trying to auto-magically transpose and correct
for link speed.

BTW, isn't there already a control message for "original interface
index"?
 
> The two values could be saved in the skb_shared_info structure. Now
> my question is if they could be useful also for other things than
> timestamping

such as?

> and if it should be a new socket option which would work
> on any socket independently from timestamping, or if it should rather
> be a new flag for the SO_TIMESTAMPING option. If the latter, would it
> make sense to put them in the skb_shared_hwtstamps structure and
> modify all drivers to set the values when a HW timestamp is captured
> instead of adding more code to __netif_receive_skb_core() or similar?

This information is solely for a highly specialized NTP application.
No normal program would ever need this, AFAICT.  So, if possible,
getting the original frame length should be done in a way that doesn't
affect users that don't need it.

Thanks,
Richard
