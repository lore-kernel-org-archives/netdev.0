From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH RFC net-next 01/21] net: add neighbour_dev_list to save
 only neighbours
Date: Tue, 3 Sep 2013 10:34:29 +0200
Message-ID: <20130903083429.GC18504@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
 <1378157965-17537-2-git-send-email-vfalico@redhat.com>
 <20130903082943.GD1437@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759552Ab3ICIfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 04:35:51 -0400
Content-Disposition: inline
In-Reply-To: <20130903082943.GD1437@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 10:29:43AM +0200, Jiri Pirko wrote:
>Mon, Sep 02, 2013 at 11:39:05PM CEST, vfalico@redhat.com wrote:
...snip...
>>-	struct list_head	upper_dev_list; /* List of upper devices */
>>-	struct list_head	lower_dev_list;
>>+
>>+	/* directly linked devices, like slaves for bonding */
>>+	struct {
>>+		struct list_head upper;
>>+		struct list_head lower;
>>+	} neighbour_dev_list ;
>>+
>>+	/* all linked devices, *including* neighbours */
>>+	struct {
>>+		struct list_head upper;
>>+		struct list_head lower;
>>+	} all_dev_list ;
>
>
>I think there is need for some naming consistency for functions and
>macros handling these lists.
>
>I propose:
>dev_list (drop the "neighbour") and all_dev_list

Agreed.

>
>and exported functions and macros called like:
>netdev_lower_get_next_priv()
>netdev_lower_for_each_priv()
>netdev_all_upper_get_next_rcu()
>etc...

Yep, will try to convert and see how it goes.

Thanks a lot!
