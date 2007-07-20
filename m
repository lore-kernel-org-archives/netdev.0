From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Fri, 20 Jul 2007 16:00:31 +0200
Message-ID: <46A0BFFF.5020000@trash.net>
References: <46A0B017.4080505@st.com> <46A0B6DE.1080904@trash.net> <46A0BF7F.80001@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard MUSIL <richard.musil@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62081 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756210AbXGTOBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 10:01:49 -0400
In-Reply-To: <46A0BF7F.80001@st.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Please quote and break your lines appropriately ]

Richard MUSIL wrote:
> Patrick McHardy wrote:
>>
>>The usual way to do this for auto-loading of modules that register
>>things that take a mutex that is already held during netlink queue
>>processing, like qdiscs, classifiers, .. is:
>>
>>- look for <qdisc/classifier/...>, if not found:
>>- drop mutex (using the __ unlock variant to avoid reentering queue
>>processing)
>>- perform module loading (which takes the mutex and registers itself)
>>- grab mutex again
>>- look for <qdisc/classifier/...> again
>>- if not found return -ENOENT
>>- if found drop reference, return -EAGAIN
>>
>>The caller is changed to handle -EAGAIN by replaying the entire
>>request. Your problem sounds very similar, look at net/sched/sch_api.c
>>for an example.
> 
> 
> The aforementioned mutex is local to genetlink module, so I cannot temporarily drop it, call the stuff and grab it again (which was mine original thought too).

Export the lock/unlock/.. functions. You'll also need a new version
similar to __rtnl_unlock.
