From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 1/9] Basic kernel memory functionality for the Memory
 Controller
Date: Mon, 12 Dec 2011 09:34:48 +0900
Message-ID: <20111212093448.91c96f77.kamezawa.hiroyu@jp.fujitsu.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
	<1323120903-2831-2-git-send-email-glommer@parallels.com>
	<20111209102113.cdb85da8.kamezawa.hiroyu@jp.fujitsu.com>
	<4EE21D23.4000309@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <lizf@cn.fujitsu.com>,
 <ebiederm@xmission.com>, <davem@davemloft.net>, <gthelen@google.com>,
 <netdev@vger.kernel.org>, <linux-mm@kvack.org>, <kirill@shutemov.name>,
 <avagin@parallels.com>, <devel@openvz.org>, <eric.dumazet@gmail.com>,
 <cgroups@vger.kernel.org>, <hannes@cmpxchg.org>, <mhocko@suse.cz>, Paul
 Menage <paul@paulmenage.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4EE21D23.4000309@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Dec 2011 12:37:23 -0200
Glauber Costa <glommer@parallels.com> wrote:

> On 12/08/2011 11:21 PM, KAMEZAWA Hiroyuki wrote:
> > Hm, why you check val != parent->kmem_independent_accounting ?
> >
> > 	if (parent&&  parent->use_hierarchy)
> > 		return -EINVAL;
> > ?
> >
> > BTW, you didn't check this cgroup has children or not.
> > I think
> >
> > 	if (this_cgroup->use_hierarchy&&
> >               !list_empty(this_cgroup->childlen))
> > 		return -EINVAL;
> 
> How about this?
> 
>          val = !!val;
> 
>          /*
>           * This follows the same hierarchy restrictions than
>           * mem_cgroup_hierarchy_write()
>           */
>          if (!parent || !parent->use_hierarchy) {
>                  if (list_empty(&cgroup->children))
>                          memcg->kmem_independent_accounting = val;
>                  else
>                          return -EBUSY;
>          }
>          else
>                  return -EINVAL;
> 
>          return 0;
> 
seems good to me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
