From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v0 5/5] cgroup: Assign subsystem IDs during compile time
Date: Mon, 20 Aug 2012 10:51:47 -0700
Message-ID: <20120820175147.GN24861@google.com>
References: <1345126336-20755-1-git-send-email-wagi@monom.org>
 <1345126336-20755-6-git-send-email-wagi@monom.org>
 <20120816232010.GJ24861@google.com>
 <502DF1DF.8040109@huawei.com>
 <502E0552.3080602@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <502E0552.3080602-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, Daniel, Li.

On Fri, Aug 17, 2012 at 10:48:18AM +0200, Daniel Wagner wrote:
> >I think so.
> 
> I am preparing an updated version which does not need the extra 1
> pointer. Some more preprocessor magic involved :)

Please try to refrain from macros as much as possible.  Let's try to
keep things C. :)

> >I'm definitely all for simplicity, but I'm not sure if we can do better in
> >simplifying the code for modularized cgroup subsystem. (I guess you didn't
> >mean to remove this feature?)
> 
> The new version should also be simpler to review because I don't
> have to touch the loops everywhere.

e.g. Why does the proposed code have different variants of
task_cls_classid() for builtin and modular cases?  Why not just use
the same code path if the ID is always static anyway?  Also, longer
term, maybe we can unify root cgroup initialization for built-in and
modular cases?

Thanks.

-- 
tejun
