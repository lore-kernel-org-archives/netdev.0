From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v8 1/9] Basic kernel memory functionality for the Memory
 Controller
Date: Fri, 9 Dec 2011 12:37:23 -0200
Message-ID: <4EE21D23.4000309@parallels.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com> <1323120903-2831-2-git-send-email-glommer@parallels.com> <20111209102113.cdb85da8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>,
	<avagin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111209102113.cdb85da8.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/08/2011 11:21 PM, KAMEZAWA Hiroyuki wrote:
> Hm, why you check val != parent->kmem_independent_accounting ?
>
> 	if (parent&&  parent->use_hierarchy)
> 		return -EINVAL;
> ?
>
> BTW, you didn't check this cgroup has children or not.
> I think
>
> 	if (this_cgroup->use_hierarchy&&
>               !list_empty(this_cgroup->childlen))
> 		return -EINVAL;

How about this?

         val = !!val;

         /*
          * This follows the same hierarchy restrictions than
          * mem_cgroup_hierarchy_write()
          */
         if (!parent || !parent->use_hierarchy) {
                 if (list_empty(&cgroup->children))
                         memcg->kmem_independent_accounting = val;
                 else
                         return -EBUSY;
         }
         else
                 return -EINVAL;

         return 0;

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
