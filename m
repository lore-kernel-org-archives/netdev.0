From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Mon, 27 Mar 2017 20:28:28 +0200
Message-ID: <20170327182828.GA2254@netboy>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
 <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
 <20170324094530.GE8192@localhost>
 <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
 <20170327101324.GI8192@localhost>
 <20170327142925.GA13305@localhost.localdomain>
 <6DE3E5F4-E69F-4334-9012-FD273ACA3C5B@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Miroslav Lichvar <mlichvar@redhat.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Denny Page <dennypage@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:34210 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751327AbdC0SfX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:35:23 -0400
Received: by mail-wr0-f172.google.com with SMTP id l43so69779449wre.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:35:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6DE3E5F4-E69F-4334-9012-FD273ACA3C5B@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 09:25:03AM -0700, Denny Page wrote:

> I agree that the values in the igb driver are incorrect. They were
> middle of the range values from the old tables. At least for 100Mb,
> Intel seems to know that the original table was incorrect. I’ve done
> extensive measurements of the i210 and i211 at both 100Mb and
> 1Gb. The “external link partner” numbers Intel currently publishes
> for the 100Mb appear accurate.

Well, after reading this, I am more convinced than ever that doing the
correction in user space is the right way.  If the one and only vendor
who publishes numbers can't even get them straight, how on earth will
we ever get the drivers right?

> I’m still finalizing the values for 1Gb, but one thing I will note
> is that the values for master mode and slave mode are quite
> different. FWIW, master/slave mode correction is also something that
> can only be corrected in the driver :)

Actually, adding ethtool support for SyncE (and consequently Gigabit
Ethernet slave/master status) is something we have discussed in the
past.  I would support expanding the interface to accommodate this...
 
> I am curious to know any data you developed in your experiments and
> how you did the measurements. Please email me directly if you are
> willing to share.

I didn't do anything super methodical, and I didn't keep notes, but I
had a phyter (whose delays were published by TI and independently
confirmed in a ISPCS paper by Christian Riesch) and an i210 with a 100
MBit link and with a PPS between them.  The phyter's numbers are
correct to within a nanosecond, and I saw that the i210 was repeatedly
landing at the published extreme of the range.  I don't remember which
extreme, and I didn't repeat more than a few times, however.

Thanks,
Richard
