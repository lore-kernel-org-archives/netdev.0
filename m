From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Mon, 27 Mar 2017 12:13:24 +0200
Message-ID: <20170327101324.GI8192@localhost>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
 <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
 <20170324094530.GE8192@localhost>
 <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Denny Page <dennypage@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47318 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752307AbdC0KNd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 06:13:33 -0400
Content-Disposition: inline
In-Reply-To: <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 10:17:51AM -0700, Denny Page wrote:
> > On Mar 24, 2017, at 02:45, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > How common is to have link speed changing in normal operation on LAN?
> 
> In my case, it’s currently every few minutes because I’m doing hw timestamp testing. :)
> 
> But this does speak to my point. If it’s cached by the application, the application has to check it regularly to minimize the possibility of bad timestamps. If the link speed doesn’t change, every call by the application is wasted overhead. If it’s cached by the driver, there is no waste, and the stamps are always correct.

At least on the HW I'm testing, reading the link speed from user space
doesn't take much. It's about 10-15x faster than reading the PHC for
instance, which must be done periodically in any case.

> I should have remembered this yesterday... I went and looked at my favorite driver, Intel's igb. Not only is the igb driver already caching link speed, it is also performing timestamp correction based on that link speed.

Isn't the i210 the only NIC for which the correction is actually
implemented? Will this ever be done for all HW with timestamping
support, so that the applications wouldn't have to care about link
speed?

> I believe that timestamp correction, whether it be speed based latency, header -> trailer, or whatever else might be needed later down the line, are properly done in the driver. It’s a lot for the application to try and figure out if it should or should not be doing corrections and what correction to apply. The driver knows.

I agree, but I'm not sure how feasible that is.

-- 
Miroslav Lichvar
