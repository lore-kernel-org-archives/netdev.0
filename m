From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6] ixgb: fix ixgb_intr looping checks
Date: Mon, 8 Nov 2004 15:10:48 -0800
Message-ID: <20041108151048.4bf605c1.akpm@osdl.org>
References: <418B2C3F.60107@pobox.com>
	<Pine.LNX.4.44.0411081446550.18540-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, jesse.brandeburg@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.LNX.4.44.0411081446550.18540-100000@isotope.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:
>
> This patch undoes a change that we believe will impact performance adversely,
> by creating possibly too long a delay between servicing completions.

Maybe.  But now take a look at how much additional pointless work will be
done in the common case.  For instance, every tx completion will incur a
call to ixgb_clean_rx_irq(), which then calls ixgb_alloc_rx_buffers().

There's quite a bit which can be optimised here.
