From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Mon, 7 Feb 2005 19:57:44 -0800
Message-ID: <20050208035744.GC8366@jm.kir.nu>
References: <4203C32A.70402@linux.intel.com> <420462BC.6010903@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Ketrenos <jketreno@linux.intel.com>, netdev@oss.sgi.com
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <420462BC.6010903@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 04, 2005 at 10:07:56PM -0800, Randy.Dunlap wrote:

> 6.  +struct ieee80211_ccmp_data {
> 
> +	u32 dot11RSNAStatsCCMPFormatErrors;
> +	u32 dot11RSNAStatsCCMPReplays;
> +	u32 dot11RSNAStatsCCMPDecryptErrors;
> 
> Are these MIB-mandated names?  otherwise the studlyCaps should go.

Well, I don't know whether it would be fair to say these are mandated as
variable names here, but yes, these are indeed the exact names used in
IEEE 802.11i MIB definition which is the reason for the variable names
here.

> 8.  What calls the .print_stats functions?
> static char * ieee80211_ccmp_print_stats()
> 
> Is it possible to use seq_file there instead of sprintf(),
> or is this in /sysfs (so seq_file is not possible)?

I used these for getting key information into procfs files. Conversion
to seq_file should be possible for procfs. This is of course assuming
that someone else has not used these for something else than procfs.

> Are there any overflow possibilities?

Should not be, these are used to create a procfs file of less than 500
bytes and the available buffer is at least a page. I did not yet look
how these are used in this patch or ipw2100/ipw2200 drivers, so this is
based on how I implemented this with Host AP driver.

-- 
Jouni Malinen                                            PGP id EFC895FA
