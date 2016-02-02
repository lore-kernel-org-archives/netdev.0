From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 7/7] net: ixgbe: add support for tc_u32 offload
Date: Mon, 01 Feb 2016 20:53:20 -0800
Message-ID: <56B03640.8050009@gmail.com>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>	<20160201015310.13871.63596.stgit@john-Precision-Tower-5810> <20160201.181715.1355993690912736292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, jesse.brandeburg@intel.com,
	jhs@mojatatu.com, ast@fb.com, donald.c.skidmore@intel.com,
	horms@verge.net.au, netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35135 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbcBBExg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 23:53:36 -0500
Received: by mail-pf0-f196.google.com with SMTP id 66so7948296pfe.2
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 20:53:36 -0800 (PST)
In-Reply-To: <20160201.181715.1355993690912736292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-01 06:17 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Sun, 31 Jan 2016 17:53:10 -0800
> 
>> +			ixgbe_jump_tables[uhtid] = nexthdr->jump;
> 
> I can't figure out what protects concurrent accesses to this shared
> ixgbe_jump_table[].  Is RTNL held here?  If so it's likely that
> GFP_ATOMIC can be changed to GFP_KERNEL in this function.
> 
> 

This is only called from tc_ctl_tfilter which is wrapped in the
rtnl_lock as you suspected.

Thanks for the catch I'll convert it to GFP_KERNEL along with the
other spot I copy pasted the GFP_ATOMIC code from.

.John
