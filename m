From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH 4/5] netdev: implement infrastructure for threadable napi irq
Date: Wed, 15 Jun 2016 07:17:37 -0700
Message-ID: <CANn89i+EJMHeMN8=e12hoT1Jv8cCBDXeexTBdsd9hU2G=HpGZA@mail.gmail.com>
References: <cover.1465996447.git.pabeni@redhat.com> <f5e431e8336f80d0e6f6b4c40c81a373db6d6052.1465996447.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f5e431e8336f80d0e6f6b4c40c81a373db6d6052.1465996447.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 15, 2016 at 6:42 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> This commit adds the infrastructure needed for threadable
> rx interrupt. A reference to the irq thread is used to
> mark the threaded irq mode.
> In threaded mode the poll loop is invoked directly from
> __napi_schedule().
> napi drivers which want to support threadable irq interrupts
> must provide an irq mode change handler which actually set
> napi->thread and register it after requesting the irq.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/linux/netdevice.h |  4 ++++
>  net/core/dev.c            | 59 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 63 insertions(+)
>

I really appreciate the effort, but as I already said this is not going to work.

Many NIC have 2 NAPI contexts per queue, one for TX, one for RX.

Relying on CFS to switch from the two 'threads' you need in the one
vCPU case will add latencies that your 'pure throughput UDP flood' is
not able to detect.

I was waiting a fix from Andy Lutomirski to be merged before sending
my ksoftirqd fix, which will work and wont bring kernel bloat.
