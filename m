From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Date: Thu, 17 May 2012 10:02:53 -0700
Message-ID: <20120517100253.3b4a1a20.akpm@linux-foundation.org>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com>
	<1336767077-25351-3-git-send-email-glommer@parallels.com>
	<20120516140637.17741df6.akpm@linux-foundation.org>
	<4FB46B4C.3000307@parallels.com>
	<20120516223715.5d1b4385.akpm@linux-foundation.org>
	<4FB4CA4D.50608@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <cgroups@vger.kernel.org>, <linux-mm@kvack.org>, <devel@openvz.org>,
 <kamezawa.hiroyu@jp.fujitsu.com>, <netdev@vger.kernel.org>, Tejun Heo
 <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner
 <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4FB4CA4D.50608@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 17 May 2012 13:52:13 +0400 Glauber Costa <glommer@parallels.com> wrote:

> Andrew is right. It seems we will need that mutex after all. Just this 
> is not a race, and neither something that should belong in the 
> static_branch interface.

Well, a mutex is one way.  Or you could do something like

	if (!test_and_set_bit(CGPROTO_ACTIVATED, &cg_proto->flags))
		static_key_slow_inc(&memcg_socket_limit_enabled);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
