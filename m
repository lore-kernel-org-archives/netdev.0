From: Anna-Maria Gleixner <anna-maria@linutronix.de>
Subject: Re: [PREEMPT-RT] [PATCH] net: mvneta: Remove superfluous SMP function
 call
Date: Tue, 5 Apr 2016 15:32:43 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1604051531060.12514@hypnos>
References: <1459761639-176299-1-git-send-email-anna-maria@linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, rt@linutronix.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459761639-176299-1-git-send-email-anna-maria@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 4 Apr 2016, Anna-Maria Gleixner wrote:

> Since commit 1cf4f629d9d2 ("cpu/hotplug: Move online calls to
> hotplugged cpu") it is ensured that callbacks of CPU_ONLINE and
> CPU_DOWN_PREPARE are processed on the hotplugged cpu. Due to this SMP
> function calls are no longer required.
> 
> Replace smp_call_function_single() with a direct call to
> mvneta_percpu_enable() or mvneta_percpu_disable(). The functions do
> not require to be called with interrupts disabled, therefore the
> smp_call_function_single() calling convention is not preserved.
> 
> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
> ---
>  drivers/net/ethernet/marvell/mvneta.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>

Please do not queue it. Heiko Carstens pointed out a problem: It isn't
ensured, that the callbacks of CPU_DOWN_FAILED are always processed on
the CPU that failed in CPU_DOWN_PREPARE (see
http://marc.info/?l=linux-s390&m=145985621421250&w=2 ). Once this
issue is fixed, I will resend the patch.

Anna-Maria
