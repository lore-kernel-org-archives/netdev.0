From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/2 2.6] e100: fix NAPI race with watchdog
Date: Wed, 22 Sep 2004 13:38:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922133823.50a66ef9@dell_ss3.pdx.osdl.net>
References: <Pine.LNX.4.44.0409221217010.7544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.LNX.4.44.0409221217010.7544-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 12:25:44 -0700 (PDT)
Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:

> While polling in NAPI mode, we were occassionally getting interrupts 
> re-enabled by the watchdog trying to generate a software interrupt.  Fix 
> is to add a spinlock around that shared hardware register to allow a 
> read-modify-write operation.  This was nasty nasty.  I don't like the 
> spinlock in the hot path but i see no other way.  Comments are welcome.
> Updates the driver version as well.

You could convert it to LLTX then at least there is only one lock roundtrip
