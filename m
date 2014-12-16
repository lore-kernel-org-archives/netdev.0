From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/5] e1000e: reset MAC-PHY interconnect on 82577/82578
Date: Tue, 16 Dec 2014 13:17:12 +0100
Message-ID: <20141216121712.GB4676@1wt.eu>
References: <1418725700-31465-1-git-send-email-Yanjun.Zhu@windriver.com> <1418725700-31465-2-git-send-email-Yanjun.Zhu@windriver.com> <1418731926.2467.15.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>, stable <stable@vger.kernel.org>,
	netdev@vger.kernel.org, Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418731926.2467.15.camel@jtkirshe-mobl>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 16, 2014 at 04:12:06AM -0800, Jeff Kirsher wrote:
> On Tue, 2014-12-16 at 18:28 +0800, Zhu Yanjun wrote:
> > 2.6.x kernels require a similar logic change as commit 6dfaa76 
> > [e1000e: reset MAC-PHY interconnect on 82577/82578] introduces
> > for newer kernels.
> > 
> > During Sx->S0 transitions, the interconnect between the MAC and PHY on
> > 82577/82578 can remain in SMBus mode instead of transitioning to the
> > PCIe-like mode required during normal operation.  Toggling the
> > LANPHYPC
> > Value bit essentially resets the interconnect forcing it to the
> > correct
> > mode.
> > 
> > after review of all intel drivers, found several instances where
> > drivers had the incorrect pattern of:
> > memory mapped write();
> > delay();
> > 
> > which should always be:
> > memory mapped write();
> > write flush(); /* aka memory mapped read */
> > delay();
> > 
> > explanation:
> > The reason for including the flush is that writes can be held
> > (posted) in PCI/PCIe bridges, but the read always has to complete
> > synchronously and therefore has to flush all pending writes to a
> > device.  If a write is held and followed by a delay, the delay
> > means nothing because the write may not have reached hardware
> > (maybe even not until the next read)
> > 
> > Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> > ---
> >  drivers/net/e1000e/defines.h |  2 ++
> >  drivers/net/e1000e/ich8lan.c | 20 ++++++++++++++++++++
> >  2 files changed, 22 insertions(+)
> 
> To be clear, Zhu is wanting this applied to stable trees (yet did not CC
> stable@vger.kernel.org ).
> 
> Willy- I am fine with this series being applied to stable.

OK, thanks Jeff! I'm queuing the patches now.

Best regards,
Willy
