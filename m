From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: e1000 kick
Date: Sat, 09 Oct 2004 10:38:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1097343522.3903.25.camel@sfeldma-mobl2.dsl-verizon.net>
References: <20041008231713.1126.qmail@web80401.mail.yahoo.com>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Huang <scott_z_huang@yahoo.com>
In-Reply-To: <20041008231713.1126.qmail@web80401.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-08 at 16:17, Scott Huang wrote:
> Is there a way to force tx dma to start on e1000 after
> the I fill up the tx ring to a certain level?

Just delay the write of the Tx tail index (TDT).  Writing to the Tx tail
index signals hardware to start the DMA from Tx head index (TDH) to
TDT.  See code for

	E1000_WRITE_REG(&adapter->hw, TDT, i);

But don't delay too long...you'll trigger the tx_timeout reset.

-scott
