From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ftrace: change the export format of
 trace_kfree_skb()
Date: Tue, 23 Jun 2009 23:58:38 -0700 (PDT)
Message-ID: <20090623.235838.129947362.davem@davemloft.net>
References: <20090610072618.GA6016@nowhere>
	<4A39B3E4.6060004@cn.fujitsu.com>
	<20090618103538.GA8978@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaoguangrong@cn.fujitsu.com, mingo@elte.hu, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rostedt@goodmis.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49227
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750720AbZFXG6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 02:58:34 -0400
In-Reply-To: <20090618103538.GA8978@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


FWIW there are parts I don't like about this change.

It's just the show_protocol_name() bit, it's designed to always be
out of date.

Nobody is going to look at trace/events/skb.h when they add a new
ETH_P_* value.

We could make some include/linux/eth_protos.def file, that has
lines like:

ETHERNET_PROTOCOL(ETH_P_FOO, N)

then headers that want to instantiate something like the usual
ETH_P_FOO defines or this symbolic printing table define
"ETHERNET_PROTOCOL" to a suitable macro and then include
linux/eth_protos.def to make the expansions.
