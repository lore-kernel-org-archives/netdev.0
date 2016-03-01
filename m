From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/8] net/flower: Introduce hardware offload
 support
Date: Tue, 1 Mar 2016 18:01:28 +0100
Message-ID: <20160301170128.GG2098@nanopsycho.orion>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
 <1456842290-7844-2-git-send-email-amir@vadai.me>
 <20160301144719.GA2098@nanopsycho.orion>
 <56d5c71f.a151c20a.cf0a8.ffffd4ad@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36449 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbcCARBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 12:01:31 -0500
Received: by mail-wm0-f68.google.com with SMTP id l68so5142580wml.3
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 09:01:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56d5c71f.a151c20a.cf0a8.ffffd4ad@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 01, 2016 at 05:49:27PM CET, amir@vadai.me wrote:
>On Tue, Mar 01, 2016 at 03:47:19PM +0100, Jiri Pirko wrote:
>> Tue, Mar 01, 2016 at 03:24:43PM CET, amir@vadai.me wrote:
>> >This patch is based on a patch made by John Fastabend.
>> >It adds support for offloading cls_flower.
>> >A filter that is offloaded successfuly by hardware, will not be added to
>> >the hashtable and won't be processed by software.
>> 
>> That is wrong. User should explitly specify to not include rule into sw
>> by SKIP_KERNEL flag (does not exist now, with John's recent patch we'll
>> have only SKIP_HW). Please add that in this patchset.
>Why? If a rule is offloaded, why would the user want to reprocess it by
>software?
>If the user use SKIP_HW, it will be processed by SW. Else, the user
>would want it to be processed by HW or fallback to SW. I don't
>understand in which case the user would like to have it done twice.

For example if you turn on the offloading by unsetting NETIF_F_HW_TC.
Or if someone inserts skbs into rx path directly, for example pktgen.
We need SKIP_KERNEL to be set by user, not implicit.
