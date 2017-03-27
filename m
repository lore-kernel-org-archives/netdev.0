From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Mon, 27 Mar 2017 16:29:25 +0200
Message-ID: <20170327142925.GA13305@localhost.localdomain>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
 <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
 <20170324094530.GE8192@localhost>
 <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
 <20170327101324.GI8192@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Denny Page <dennypage@me.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38078 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752686AbdC0Oi2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 10:38:28 -0400
Received: by mail-wm0-f41.google.com with SMTP id t189so20673966wmt.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 07:38:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170327101324.GI8192@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 12:13:24PM +0200, Miroslav Lichvar wrote:
> On Fri, Mar 24, 2017 at 10:17:51AM -0700, Denny Page wrote:
> > I should have remembered this yesterday... I went and looked at my favorite driver, Intel's igb. Not only is the igb driver already caching link speed, it is also performing timestamp correction based on that link speed.
> 
> Isn't the i210 the only NIC for which the correction is actually
> implemented?

Yes.

> Will this ever be done for all HW with timestamping
> support, so that the applications wouldn't have to care about link
> speed?

No.

At the end of the day, the correction in the igb driver is useless and
even harmful.  Why?  Because if the app cares about this level of
accuracy, it is going to have to implement special logic anyhow, and
having a special case for the igb is even more work for the app.

In addition, if you look into the igb data sheet, you will find a
range of correction values, with little indication of how they
measured the latency and what the ranges depend on.  In my
experiments, I have seen the igb consistently land on the extreme of
one of the ranges (who knows why), but the driver corrects using the
average, forcing me then to correct the remaining offset by hand.

> > I believe that timestamp correction, whether it be speed based latency, header -> trailer, or whatever else might be needed later down the line, are properly done in the driver. It’s a lot for the application to try and figure out if it should or should not be doing corrections and what correction to apply. The driver knows.
> 
> I agree, but I'm not sure how feasible that is.

+1

Thanks,
Richard
