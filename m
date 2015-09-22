From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] lib: fix data race in rhashtable_rehash_one
Date: Tue, 22 Sep 2015 10:19:58 +0200
Message-ID: <20150922081958.GC13047@pox.localdomain>
References: <1442822930-35319-1-git-send-email-dvyukov@google.com>
 <1442842315.29850.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <1442847108.29850.56.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150921222538.GA31246@pox.localdomain>
 <1442876618.29850.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kcc@google.com,
	andreyknvl@google.com, glider@google.com, ktsan@googlegroups.com,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442876618.29850.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/21/15 at 04:03pm, Eric Dumazet wrote:
> What I said is :
> 
> In @head you already have the correct nulls value, from hash table.
> 
> You do not need to recompute this value, and/or test if hash table chain
> is empty.
> 
> If hash bucket is empty, it contains the appropriate NULLS value.
> 
> If you are paranoiac add this debugging check :
> 
> if (rht_is_a_nulls(head))
>     BUG_ON(head != (struct rhash_head *)rht_marker(ht, new_hash));
> 
> 
> Therefore, simply fix the bug and unnecessary code with :

You are absolutely right Eric. Do you want to revise your patch Dmitry?
Eric's proposed fix absolutely the best way to fix this.
