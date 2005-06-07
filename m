From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 7 Jun 2005 14:36:12 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0506071432570.16594@tux.rsn.bth.se>
References: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408>
 <Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>
 <42A5284C.3060808@osdl.org>  <1118147904.6320.108.camel@localhost.localdomain>
  <Pine.LNX.4.58.0506071351080.16594@tux.rsn.bth.se>
 <1118150948.6320.152.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>,
        Mitch Williams <mitch.a.williams@intel.com>,
        "Ronciak, John" <john.ronciak@intel.com>,
        "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1118150948.6320.152.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Jun 2005, jamal wrote:

> On Tue, 2005-07-06 at 14:06 +0200, Martin Josefsson wrote:
>
> > One thing that jumps to mind is that e1000 starts at lastrxdescriptor+1
> > and loops and checks the status of each descriptor and stops when it finds
> > a descriptor that isn't finished. Another way to do it is to read out the
> > current position of the ring and loop from lastrxdescriptor+1 up to the
> > current position. Scott Feldman implemented this for TX and there it
> > increased performance somewhat (discussed here on netdev some months ago).
> > I wonder if it could also decrease RX latency, I mean, we have to get the
> > cache miss sometime anyway.
> >
>
> The effect of Scotts patch was to reduce IO by amortizing it on the TX
> side. Are we talking about the same thing ? This was in the case of TX
> descriptor prunning?

Yes, that was for TX pruning.

> So it is possible that the e1000 is doing more than necessary share of
> IO on the receive side as well.

Yes, that's what I mean. Same thing but for RX but the question is how
much we would gain from it, we still need to touch the rx-descriptor
sooner or later. Would be worth a test.
My testsetup isn't in a working condition right now, Robert?

/Martin
