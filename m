From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] openvswitch: fix error return code in
 ovs_vport_cmd_set()
Date: Wed, 20 Mar 2013 12:22:13 -0400 (EDT)
Message-ID: <20130320.122213.135318342578938888.davem@davemloft.net>
References: <CAPgLHd_6+xnMKZBzH3KySpFv7hUzzNot7GBYSCAPLDRbC5HjsA@mail.gmail.com>
	<CAEP_g=8zxp4jcNN93iEGzA2aNbmM7g+=PaWbTEyJiwzwS5Qnsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, yongjun_wei@trendmicro.com.cn,
	dev@openvswitch.org, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701Ab3CTQWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:22:15 -0400
In-Reply-To: <CAEP_g=8zxp4jcNN93iEGzA2aNbmM7g+=PaWbTEyJiwzwS5Qnsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Wed, 20 Mar 2013 08:57:53 -0700

> On Wed, Mar 20, 2013 at 5:14 AM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> Fix to return a negative error code from the error handling
>> case instead of 0, as returned elsewhere in this function.
>>
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> This isn't right because at this point in the function the change has
> already been made, only the notification allocation failed.  Therefore
> we don't want to return an error since the caller will assume that
> nothing has changed; instead an error is set on the Netlink socket.

Then the way to fix this is to allocate the netlink SKB first, before
any config changes occur, then pass that SKB into ovs_vport_cmd_build_info.

We can still get errors, for -EMSGSIZE situations, but I'd say that'd
be an implementation bug that should be logged.  If we aren't allocating
large enough SKBs for the netlink reply, that's really an internal
error.
