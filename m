From: "David S. Miller" <davem@redhat.com>
Subject: Re: Kernel crash in 2.6.0-test9-mm3
Date: Tue, 18 Nov 2003 18:24:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118182442.7e9ea7e9.davem@redhat.com>
References: <OF0696EDA9.D66EB77E-ON88256DE3.0009C15A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: reuben-linux@reub.net, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>, scott.feldman@intel.com
In-Reply-To: <OF0696EDA9.D66EB77E-ON88256DE3.0009C15A@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Nov 2003 18:22:42 -0800
Krishna Kumar <kumarkr@us.ibm.com> wrote:

> Could this be happening on an SMP system only ? If so, e100intr routine
> services tx queues (e100_tx_srv) without holding a lock.

[ Scott we have a bug report, and we're trying to determine if the
  cause is that the e100 driver frees a TX SKB multiple times due
  to some race or other problem in current 2.6.x ]

That's a very good point, and I looked a bit in this area.

When e100intr() is doing it's work, it disables and clears
the interrupt, only after doing RX and TX processing does
it reenable chip interrupts via e100_set_intr_mask().

That is my analysis of the situation.

However, with things like IOAPIC and such, it might be possible
for two cpus to enter e100intr() simultaneously, both read
the same status, both see that the interrupt is pending, and
both thus process the interrupt and race with each other.

Scott, what prevents the above from happening?
