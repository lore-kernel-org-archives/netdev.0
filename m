From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 17:25:36 -0700
Message-ID: <1117844736.4430.51.camel@rh4>
References: <20050603.120126.41874584.davem@davemloft.net>
 <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
 <20050603.132257.23013342.davem@davemloft.net>
 <20050603.132922.63997492.davem@davemloft.net>
 <1117828169.4430.29.camel@rh4>
 <20050603205944.GC20623@xi.wantstofly.org>
 <1117830922.4430.44.camel@rh4>
 <1117837798.6266.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Lennert Buytenhek" <buytenh@wantstofly.org>,
        "David S. Miller" <davem@davemloft.net>, mitch.a.williams@intel.com,
        john.ronciak@intel.com, jdmason@us.ibm.com, shemminger@osdl.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1117837798.6266.25.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-03 at 18:29 -0400, jamal wrote:
> On Fri, 2005-03-06 at 13:35 -0700, Michael Chan wrote:
> 
> > By the way, in tg3 there is a buffer replenishment threshold programmed
> > to the chip and is currently set at rx_pending / 8 (200/8 = 25). This
> > means that the chip will replenish 25 rx buffers at a time.
> > 
> 
> So when you write the MMIO, 25 buffers are replenished or is this auto
> magically happening in the background? Sounds like a neat feature either
> way.
> 
The MMIO writes a cumulative producer index of new rx descriptors in the
ring. As the chip requires new buffers for rx packets, it will DMA 25 of
these rx descriptors at a time up to the producer index.
