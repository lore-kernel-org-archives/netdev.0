From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 18:29:58 -0400
Message-ID: <1117837798.6266.25.camel@localhost.localdomain>
References: <20050603.120126.41874584.davem@davemloft.net>
	 <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
	 <20050603.132257.23013342.davem@davemloft.net>
	 <20050603.132922.63997492.davem@davemloft.net>
	 <1117828169.4430.29.camel@rh4> <20050603205944.GC20623@xi.wantstofly.org>
	 <1117830922.4430.44.camel@rh4>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        "David S. Miller" <davem@davemloft.net>, mitch.a.williams@intel.com,
        john.ronciak@intel.com, jdmason@us.ibm.com, shemminger@osdl.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1117830922.4430.44.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-06 at 13:35 -0700, Michael Chan wrote:
> On Fri, 2005-06-03 at 22:59 +0200, Lennert Buytenhek wrote:

> > Which makes a lot more sense, since you'd rather do one MMIO write
> > at the end of the loop than one per iteration, especially if your
> > MMIO read (flush) latency is high.  (Any subsequent MMIO read will
> > have to flush out all pending writes, which'll be slow if there's
> > a lot of writes still in the queue.)
> > 
> I agree on the merit of issuing only one IO at the end. What I'm saying
> is that doing so will make it similar to e1000 where all the buffers are
> replenished at the end. Isn't that so or am I missing something?
> 

I think the main issue would be a lot less CPU used in your case
(because of the single MMIO).

> By the way, in tg3 there is a buffer replenishment threshold programmed
> to the chip and is currently set at rx_pending / 8 (200/8 = 25). This
> means that the chip will replenish 25 rx buffers at a time.
> 

So when you write the MMIO, 25 buffers are replenished or is this auto
magically happening in the background? Sounds like a neat feature either
way.

cheers,
jamal
