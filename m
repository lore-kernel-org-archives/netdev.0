From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Tue, 08 Feb 2005 03:41:59 -0600
Message-ID: <42088967.2020901@linux.intel.com>
References: <4203C32A.70402@linux.intel.com> <420462BC.6010903@osdl.org> <20050208035744.GC8366@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20050208035744.GC8366@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:

>On Fri, Feb 04, 2005 at 10:07:56PM -0800, Randy.Dunlap wrote:
>
>  
>
>>6.  +struct ieee80211_ccmp_data {
>>
>>+	u32 dot11RSNAStatsCCMPFormatErrors;
>>+	u32 dot11RSNAStatsCCMPReplays;
>>+	u32 dot11RSNAStatsCCMPDecryptErrors;
>>
>>Are these MIB-mandated names?  otherwise the studlyCaps should go.
>>    
>>
>
>Well, I don't know whether it would be fair to say these are mandated as
>variable names here, but yes, these are indeed the exact names used in
>IEEE 802.11i MIB definition which is the reason for the variable names
>here.
>  
>
A thought that has been at the back of my mind is if we will ever want 
to fully export the MIBs for 802.11, and if so, are there any minimal 
overhead ways of doing so from kernel drivers?

>>8.  What calls the .print_stats functions?
>>static char * ieee80211_ccmp_print_stats()
>>
>>Is it possible to use seq_file there instead of sprintf(),
>>or is this in /sysfs (so seq_file is not possible)?
>>    
>>
>
>I used these for getting key information into procfs files. Conversion
>to seq_file should be possible for procfs. This is of course assuming
>that someone else has not used these for something else than procfs.
>  
>
>>Are there any overflow possibilities?
>>    
>>
>Should not be, these are used to create a procfs file of less than 500
>bytes and the available buffer is at least a page. I did not yet look
>how these are used in this patch or ipw2100/ipw2200 drivers, so this is
>based on how I implemented this with Host AP driver.
>  
>
The ipw* drivers currently don't use the print_stats callbacks.

Do we want to maintain this capability of the ciphers to be able to 
output freeform data, or should this be incorporated into a more defined 
output structure for use by user space tools and exported by the 
ieee80211 subsystem?

James
