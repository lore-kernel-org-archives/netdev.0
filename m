From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH 11/21] e1000: disable CRC stripping workaround
Date: Thu, 22 Jun 2006 09:01:21 -0700
Message-ID: <4807377b0606220901q1e2afbci44120db29a3d0bbc@mail.gmail.com>
References: <20060622051815.25497.89192.stgit@gitlost.site>
	 <20060622052029.25497.67575.stgit@gitlost.site>
	 <449A2B20.2020006@candelatech.com>
	 <4807377b0606220839i5de14797ocb9e404fd21540e3@mail.gmail.com>
	 <449ABD6D.9090808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:38895 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751835AbWFVQBW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 12:01:22 -0400
Received: by ug-out-1314.google.com with SMTP id a2so562981ugf
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 09:01:21 -0700 (PDT)
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <449ABD6D.9090808@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/22/06, Ben Greear <greearb@candelatech.com> wrote:
> Jesse Brandeburg wrote:
> > On 6/21/06, Ben Greear <greearb@candelatech.com> wrote:
> >
> >> Kok, Auke wrote:
> >> > CRC stripping is breaking SMBUS-connected BMC's. We disable this
> >> > feature to make it work. This fixes related bugs regarding SOL.
> >>
> >> Shouldn't you also have to subtract 4 bytes when setting the skb len
> >> in the receive logic?  Perhaps when setting the rx-bytes counter as well?
> >
> >
> > we thought about this, but most drivers don't strip the CRC, and we
> > couldn't find any tests including bridging that cared if the CRC was
> > there in the indicated packet.
> >
> > If you can find me a failing case I'll fix it.  It was much simpler to
> > leave it out, especially when we add back in the multiple descriptor
> > receive code in the future (think about the case when subtracting the
> > CRC makes the last descriptor disappear)
> >
> > Once again, let me know if you have info I don't :-)
>
> It should only be a problem if skb->len includes the extra 4 bytes for
> the crc.  Then, if I transmit that skb to another interface, I am afraid
> that the crc will be seen as data in the packet.  In the 2.6.13 days,
> the e1000 did not strip the CRC, but it subtracted 4 before it did the
> skb_put.  So, the crc was correctly stripped/ignored.  The e100
> functioned similarly I believe.

currently the e100 driver in 2.6.X strips the CRC in hardware.

> If you skb_put the extra 4 bytes, I believe this will break my
> (proprietary) app because on transmit it will append the extra 4 crc
> bytes, but that isn't your problem..and I can work around it.  If the
> receiving NIC can handle pkts 4 bytes bigger than normal, it will
> probably still receive the packet w/out problem, but in truth, the frame
> will not be exactly correct.
>
> When you did your bridging tests, did you sniff the packets on the far
> side of the bridge to see if they were the right size?

hm, probably not, we touch tested bridging (probably with TCP), and
have completed several internal testing passes, to make sure it worked
but I don't think we went so far as to   sniff the traffic at the
other end of the bridge.  I'll look into it.

Jesse
