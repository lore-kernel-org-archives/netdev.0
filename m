From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Sat, 24 Jun 2006 10:13:51 -0400
Message-ID: <1151158431.6716.95.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>
	 <1150292693.5197.1.camel@jzny2>
	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>
	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
	 <1151000966.5392.34.camel@jzny2>
	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:47544 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750766AbWFXON6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jun 2006 10:13:58 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fu8tc-00011u-0f
	for netdev@vger.kernel.org; Sat, 24 Jun 2006 10:14:00 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1151066247.4217.254.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-23-06 at 22:37 +1000, Russell Stuart wrote: 
>  Sorry for the digest like reply :(

;-> I know this discussion has gone in a few directions already
and i am sure as you kept responding to the emails it became obvious.
Let me just jump to one point so we dont repeat a lot of the same things
over and over..
You can actually stop reading here if you have gathered the view at
this point that i am not objecting to the simple approach Patrick is
going with...

> On Tue, 2006-06-20 at 10:06 -0400, jamal wrote:
>  But you can measure the bandwidth you are 
> getting from your ISP and plug that into the tc command 
> line.  The web page I sent to you describes how to do this
> for ADSL lines.
> 

Indeed and i referred to it in the exchanges. 
And yes, I was arguing that the tc scheme you describe would not be so
bad either if the cost of making a generic change is expensive.

To reiterate the scheduler "owns the resources" of the link
i.e link level bandwidth - aka throughput; however, teaching the
scheduler as in your description in that page about effective
throughput aka "goodput" is also within reason if you knew _it was
consistent_ . The diagram i drew was:

|Linux| --ethernet-- |Modem| --DSL-- |DSLAM| --ATM-- |BRAS| 

As can be seen from above, Linux has direct ownership of the ethernet
link resources (within limits of fixed bandwidth no AN etc). Just like a
disk quota scheduler owns the disk resources or CPU scheduler owns the
CPU cycles etc. Likewise, the DSLAM downstream owns scheduling of the
ATM link resources.

if you have knowledge that ATM runs between DSLAM and BRAS and that
the effective throughput is in-fact lower than the advertised one at
that point in the end2end path, then i admit it is fine to do as you
described in your web-page. 
Given the ubiquity of ADSL it is also ok to have simple tweak knobs for
the scheduler in Linux to allow for it to be able to compensate for the
ATM fragmentation 3 hops down. 

There are a lot of link layer issues that you may end up knowing of
(other than the ATM fragmentation overhead) in regards to something
downstream and you keep adding knobs is just adding more bloat. 
Example: If that 3rd hop was wireless that happened to be doing CDMA RLP
with a lot of retransmits, or wireless that varied its throughput from
1-3Mbps at any point in time or it was a satellite link that had a lot
of latency etc etc. You could always have some way to tweak these via
the kernel. In-fact people have written schedulers specifically for
these sorts of link layer problems (I think even some of the IEEE 802.11
or wimax folks have standardized specific schedulers). You basically
have to draw a line somewhere. My line was "can it be done via user
space? yes - do it there".

Patrick seems to have a simple way to compensate generically for link
layer fragmentation, so i will not argue the practically; hopefully that
settles it? ;->

cheers,
jamal

