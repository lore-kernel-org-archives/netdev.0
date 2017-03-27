From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Mon, 27 Mar 2017 09:25:03 -0700
Message-ID: <6DE3E5F4-E69F-4334-9012-FD273ACA3C5B@me.com>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost> <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
 <20170324094530.GE8192@localhost>
 <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
 <20170327101324.GI8192@localhost>
 <20170327142925.GA13305@localhost.localdomain>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Miroslav Lichvar <mlichvar@redhat.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp001.me.com ([17.172.125.149]:43438 "EHLO
        st11p06im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751367AbdC0QZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 12:25:26 -0400
Received: from process-dkim-sign-daemon.st11p06im-asmtp001.me.com by
 st11p06im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0ONH00K00EW1F000@st11p06im-asmtp001.me.com> for netdev@vger.kernel.org;
 Mon, 27 Mar 2017 16:25:07 +0000 (GMT)
In-reply-to: <20170327142925.GA13305@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 27, 2017, at 07:29, Richard Cochran <richardcochran@gmail.com> =
wrote:
>=20
> At the end of the day, the correction in the igb driver is useless and
> even harmful.  Why?  Because if the app cares about this level of
> accuracy, it is going to have to implement special logic anyhow, and
> having a special case for the igb is even more work for the app.

If you are doing correction in the application, _every_ driver is a =
special case. The a driver making average (known) correction is no more =
special than any other.


> In addition, if you look into the igb data sheet, you will find a
> range of correction values, with little indication of how they
> measured the latency and what the ranges depend on.

You are looking at the 2.2 datasheet I expect. The values for 10Mb and =
1Gb have been removed from subsequent datasheets, however they have =
added a bit more detail as to how the values are measured and what the =
values.


> In my
> experiments, I have seen the igb consistently land on the extreme of
> one of the ranges (who knows why), but the driver corrects using the
> average, forcing me then to correct the remaining offset by hand.

I agree that the values in the igb driver are incorrect. They were =
middle of the range values from the old tables. At least for 100Mb, =
Intel seems to know that the original table was incorrect. I=E2=80=99ve =
done extensive measurements of the i210 and i211 at both 100Mb and 1Gb. =
The =E2=80=9Cexternal link partner=E2=80=9D numbers Intel currently =
publishes for the 100Mb appear accurate. I=E2=80=99m still finalizing =
the values for 1Gb, but one thing I will note is that the values for =
master mode and slave mode are quite different. FWIW, master/slave mode =
correction is also something that can only be corrected in the driver :)

I am curious to know any data you developed in your experiments and how =
you did the measurements. Please email me directly if you are willing to =
share.

Thanks,
Denny
