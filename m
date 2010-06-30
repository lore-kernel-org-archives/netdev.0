From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next-2.6 PATCH 1/8] e1000e: cleanup ethtool loopback setup
	code
Date: Wed, 30 Jun 2010 15:41:19 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A9001591F6130@orsmsx509.amr.corp.intel.com>
References: <20100616232523.4834.84849.stgit@localhost.localdomain>
 <20100618.221512.102550313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:61275 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754488Ab0F3WlW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 18:41:22 -0400
In-Reply-To: <20100618.221512.102550313.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, June 18, 2010 10:15 PM, David Miller wrote:
> I've applied this series however:
> 
> 1) Please address Ben's concerns about turning EEE on by default
>    given that standardization is not complete yet.
> 
> 2) I hate module parameters, I'd rather you create a new ethtool
>    feature bit and thus allow the setting to be modified at run
>    time.  Please create a new ethtool control flag, and remove
>    this module option.
> 
> Thanks.

Hi Dave,

I've been looking into your request number 2 above (as a reminder, it had to do with a patch I submitted that added a module parameter to e1000e in order to enable/disable Energy Efficient Ethernet for a particular type of adapter).

For this new ethtool feature bit/flag for EEE, would you prefer it be set via:
1) the generic parameter setting option (e.g. -s ethX [eee on|off]),
2) yet another new show/change option pair, or
3) a new option that can set this new feature and be expandable to future features that are likewise not related to existing ethtool options (e.g. -F [eee on|off] [whizbang on|off])?

For #2 or #3, it makes sense to use ethtool_op_[g|s]et_flags with new ETH_FLAG_<feature> and NETIF_F_<feature> defines, but #1 can be implemented that way or by using remaining reserved elements of struct ethtool_cmd - if your preference is for #1, would you prefer it be implemented with the former or latter?

Thanks,
Bruce.