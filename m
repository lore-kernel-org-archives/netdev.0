From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Constantly varying download rate with a complex xen networking
 setup, why?
Date: Mon, 15 Jun 2009 19:36:36 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0906151910220.16408@melkinkari.cs.Helsinki.FI>
References: <20090615075313.GA22819@rivendell>
 <Pine.LNX.4.64.0906151657380.16408@melkinkari.cs.Helsinki.FI>
 <20090615160254.GA8550@rivendell>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243445-1085278168-1245082320=:16408"
Cc: Netdev <netdev@vger.kernel.org>
To: Raphael Hertzog <raphael@ouaza.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35760 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706AbZFOQgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 12:36:35 -0400
In-Reply-To: <20090615160254.GA8550@rivendell>
Content-ID: <Pine.LNX.4.64.0906151915470.16408@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-1085278168-1245082320=:16408
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0906151915471.16408@melkinkari.cs.Helsinki.FI>

On Mon, 15 Jun 2009, Raphael Hertzog wrote:

> Le lundi 15 juin 2009, Ilpo Järvinen a écrit :
> > On Mon, 15 Jun 2009, Raphael Hertzog wrote:
> > 
> > > My problem is that when I download a big file from the internet by HTTP in
> > > the dom0, the download rate is not stable. It goes up progressively and then
> > > stalls for a few seconds, and restart again going up progressively (and
> > > all this in loop until the download is complete).
> > 
> > My guess: TCP sawtooth pattern and the associated loss recovery...? What 
> > you describe here seems to match exactly to what is expected to happen 
> > because of it (I see this happening quite often actually).
> 
> Why would this not happen for the same transfer done through a proxy (that
> runs on the same machine but different domU)?

Maybe the proxy interferes there somehow... I don't know enough about the
details to say but I suppose the proxy at least breaks your tcp connection 
to two parts.

It could well be something else. I was just saying that this 
increasing+stall+repeat pattern itself is quite typical also during normal 
operation (with short rtts one can't see that though due to humanly 
limitations in perception :-) and because of the granularity the 
reporting).

> > What is the size of the bottleneck buffer and base RTTs of the relevant
> > flows (HTTP, ssh)?
> 
> How can I collect those information?

Perhaps it's enough to just know if sshs that stall go over the adsl link 
too or are they local? If they're local it's sort of pointing to something 
else (of which I probably have no clue).

> > Please verify "blocking" using tcpdump or so. You may find out e.g. that 
> 
> I'll try to do so and follow-up.
> 
> > network is not stalled but that out-of-order arrivals prevent 
> > applications from making progress.
> > 
> > If this matches with your problem, deploying AQM at the bottleneck would 
> > help.
> 
> The bottleneck in my test setup is the ADSL connection and I don't control
> the ADSL router.

Right, those non-controllable things need a bit more sophisticated 
control. Lartc has some pre-made script which basically puts an articifial 
cap on the receiver side slightly below the downlinkg rate to create 
bottleneck there which in turn allows controlling the queue.


-- 
 i.
---696243445-1085278168-1245082320=:16408--
