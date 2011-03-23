From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH V12 3/4] ptp: Added a clock driver for the IXP46x.
Date: Wed, 23 Mar 2011 14:43:00 -0700
Message-ID: <1300916580.848.51.camel@work-vm>
References: <cover.1298878618.git.richard.cochran@omicron.at>
	 <cd6ddff0dcca60ac88b35660505d7bf54ad32405.1298878618.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@arm.linux.org.uk>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cd6ddff0dcca60ac88b35660505d7bf54ad32405.1298878618.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-02-28 at 08:58 +0100, Richard Cochran wrote:
> This patch adds a driver for the hardware time stamping unit found on the
> IXP465. The basic clock operations and an external trigger are implemented.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> Acked-by: John Stultz <johnstul@us.ibm.com>

My ack is still fine, but found a few more nits to consider on another
pass... 


> +static int match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seq)
[snip]
> +static void do_rx_timestamp(struct port *port, struct sk_buff *skb)
[snip]
> +static u64 sys_time_read(struct ixp46x_ts_regs *regs)
[snip]
> +static void sys_time_write(struct ixp46x_ts_regs *regs, u64 ns)

I know these are static, but these function names are sort of generic
names, and make grep/cscoping for similar sounding functions a little
noisy. 

Maybe add a ipx_ prefix just to be more obvious?

thanks
-john
