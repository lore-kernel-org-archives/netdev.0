From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Wed, 26 May 2004 11:01:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526110121.657f2d42.davem@redhat.com>
References: <B1508D50A0692F42B217C22C02D849727FEDB8@NT-IRVA-0741.brcm.ad.broadcom.com>
	<20040526160443.GD4557@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040526160443.GD4557@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 May 2004 02:04:43 +1000
Greg Banks <gnb@sgi.com> wrote:

> On a related note, is there a good reason why the tg3 driver uses
> the on-chip SRAM send ring by default instead of the host send ring?
> This seems like it would dramatically increase the PIO load on the
> chipset for some of the workloads I'm interested in.

Good question.

It actually results in better performance to use PIOs to the
chip to write the TXD descriptors.  You may be skeptical about
this but it cannot be denied that it does result in lower
latency as we don't have to wait for the chip to do it's next
prefetch and _furthermore_ this means that no CPU cache lines
will bounce from cpu-->device in order to get the descriptors
to the chip.
