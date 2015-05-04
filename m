From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: Re: [PATCH] net: macb: Do not enable RX buffer used interrupt
Date: Mon, 4 May 2015 17:18:04 -0500
Message-ID: <20150504221804.GA24341@nathan3500-linux-VM>
References: <1430761396-4878-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430761396-4878-1-git-send-email-nathan.sullivan@ni.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 04, 2015 at 12:43:15PM -0500, Nathan Sullivan wrote:
> This driver does not handle the RX buffer used interrupt, nor does
> it need to due to handling the RX overflow interrupt already.  Enabling
> the interrupt would lead to an infinite loop in the ISR.
>

Well, that may have been premature.  We are seeing the RXUBR interrupt get
stuck asserted on Zynq hardware, and I failed to realize the driver clears
RXUBR already in macb_interrupt...  Not enabling that interrupt keeps my 
system responsive, but it's not the correct solution to this issue.
