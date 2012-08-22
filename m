From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 13/17] lockd: use new hashtable
	implementation
Date: Wed, 22 Aug 2012 19:32:52 +0200
Message-ID: <503517C4.5030500@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
	<1345602432-27673-14-git-send-email-levinsasha928@gmail.com>
	<20120822114752.GC20158@fieldses.org>
	<5034CD02.2010103@gmail.com> <20120822132243.GA2844@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120822132243.GA2844@Krystal>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/22/2012 03:22 PM, Mathieu Desnoyers wrote:
> * Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
>> On 08/22/2012 01:47 PM, J. Bruce Fields wrote:
>>> On Wed, Aug 22, 2012 at 04:27:08AM +0200, Sasha Levin wrote:
>>>> +static int __init nlm_init(void)
>>>> +{
>>>> +	hash_init(nlm_files);
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +module_init(nlm_init);
>>>
>>> That's giving me:
>>>
>>> fs/lockd/svcsubs.o: In function `nlm_init':
>>> /home/bfields/linux-2.6/fs/lockd/svcsubs.c:454: multiple definition of `init_module'
>>> fs/lockd/svc.o:/home/bfields/linux-2.6/fs/lockd/svc.c:606: first defined here
>>> make[2]: *** [fs/lockd/lockd.o] Error 1
>>> make[1]: *** [fs/lockd] Error 2
>>> make[1]: *** Waiting for unfinished jobs....
>>
>> I tested this entire patch set both with linux-next and Linus' latest master,
>> and it worked fine in both places.
>>
>> Is it possible that lockd has a -next tree which isn't pulled into linux-next?
>> (there's nothing listed in MAINTAINERS that I could see).
> 
> fs/lockd/Makefile:
> 
> obj-$(CONFIG_LOCKD) += lockd.o
> 
> lockd-objs-y := clntlock.o clntproc.o clntxdr.o host.o svc.o svclock.o \
>                 svcshare.o svcproc.o svcsubs.o mon.o xdr.o grace.o
> 
> your patch adds a module_init to svcsubs.c.
> However, there is already one in svc.c, pulled into the same module.
> 
> in your test build, is CONFIG_LOCKD defined as "m" or "y" ? You should
> always test both.
> 
> One solution here is to create a "local" init function in svcsubs.c and
> expose it to svc.c, so the latter can call it from its module init
> function.

Ah yes, it was on =y and I didn't notice :/

I'll fix that.

> Thanks,
> 
> Mathieu
> 
