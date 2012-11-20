From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH 7/7] netprio_cgroup: allow nesting and inherit config
	on cgroup creation
Date: Tue, 20 Nov 2012 16:10:46 +0100
Message-ID: <50AB9D76.3010809@monom.org>
References: <1353400211-5182-1-git-send-email-tj@kernel.org>
	<1353400211-5182-8-git-send-email-tj@kernel.org>
	<50AB45EA.2050507@monom.org>
	<20121120144036.GP15971@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	tgraf-G/eBtMaohhA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121120144036.GP15971-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 20.11.2012 15:40, Tejun Heo wrote:
> Hello, Daniel.
>
> On Tue, Nov 20, 2012 at 09:57:14AM +0100, Daniel Wagner wrote:
>>> -static void cgrp_css_free(struct cgroup *cgrp)
>>> +static int cgrp_css_online(struct cgroup *cgrp)
>>>   {
>>> -	struct cgroup_netprio_state *cs = cgrp_netprio_state(cgrp);
>>> +	struct cgroup *parent = cgrp->parent;
>>>   	struct net_device *dev;
>>> +	int ret = 0;
>>> +
>>> +	if (!parent)
>>> +		return 0;
>>
>> BTW, parent is always != NULL, because the root cgroup will be
>> attached to the dummytop cgroup.
>
> Hmmm?  I'm confused.  When ->css_online() is called for dummytop in
> cgroup_init_subsys(), its parent is NULL.  What am I missing?

Forget my comment, I was really confused when writing this. I was 
looking only at cgroups which were created after bootup.

cheers,
daniel
