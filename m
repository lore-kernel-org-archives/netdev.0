From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Locking model for NAPI drivers
Date: Wed, 01 Jun 2005 14:34:10 -0700
Message-ID: <1117661650.4310.62.camel@rh4>
References: <20050531.154847.63995530.davem@davemloft.net>
 <1117658019.4310.58.camel@rh4>
 <20050601.152134.120445266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050601.152134.120445266.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-06-01 at 15:21 -0700, David S. Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 01 Jun 2005 13:33:39 -0700
> 
> > I suppose we can enable interrupts in tg3_irq_quiesce() after setting
> > the SYNC bit.
> 
> Since the caller shuts down NAPI ->poll(), after setting the SYNC bit
> we can just check the MAILBOX register, and if a '1' is there just
> return.  Does one need to mask out the upper bits of the regiser in
> order to avoid seeing the IRQ tag in such a comparison?
> 
No, just check for the value 1 since that's the value we use to disable
interrupts. The value read back will always be 1 if 1 was previously
written to it.
