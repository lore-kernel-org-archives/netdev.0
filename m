From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] - e1000_ethtool.c - convert macros to
	functions
Date: Wed, 31 Oct 2007 17:39:49 -0700
Message-ID: <47292055.5070107@intel.com>
References: <1193865488.11020.11.camel@localhost>	 <4728F3E1.1040908@intel.com>
	<1193872556.11020.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	"Kok,  Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <1193872556.11020.34.camel@localhost>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> On Wed, 2007-10-31 at 14:30 -0700, Kok, Auke wrote:
>> Joe Perches wrote:
>> that's not a bad idea, however see below:
>> can't we keep the macro here (and just make it call the function instead of
>> expanding). the resulting code is much more lenghty and contains all these logic
>> traps that the previous code didn't have.
>> just have the macro expand to `if (reg_pattern_test(...)) return 1)` and you don't
>> need to change any of the calling lines.
> 
> You could define something like:
> 
> #define REG_PATTERN_TEST(reg, mask, write) \
> 	if (reg_pattern_test(adapter, data, \
> 			     E1000_REG(&adapter->hw, reg), \
> 			     mask, write)) \
> 		return 1;
> 
> But isn't the macro with an embedded return a bit too obfuscating?

in this case it saves a bunch of time reading and makes the code actually more
readable and robust IMO. Now we're explicitly mobming out on an error. with your
patch we need to assure that for every call to reg_pattern_test we check the
return value.

>>> +#define E1000_READ_REG_ARRAY(a, reg, offset)		\
>>> +	(readl((a)->hw_addr +				\
>>> +	       (((a)->mac_type >= e1000_82543)		\
>>> +		? E1000_##reg : E1000_82542_##reg) +	\
>>> +	       ((offset) << 2)))
>> did you have to change these macro's ?
> 
> No.  Your choice to keep/remove.
> I did want to use the E1000_REG or a new E1000_REG_ADDR macro.
> 
>> also, I'm a bit inclined to prefer a patch for e1000e for now as we're about to
>> move the pci-express hardware over, but we can certainly merge something like this
>> in e1000 after the move as well.
> 
> Simple enough.
> 
> When is e1000e scheduled to be part of defconfig?

I don't know about defconfig, but you can already get e1000 in 2.6.24rc1...

Auke


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
