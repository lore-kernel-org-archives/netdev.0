From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH v2 net-next 1/3] bpf: enable non-root eBPF programs
Date: Fri, 9 Oct 2015 11:28:22 +0200
Message-ID: <20151009092822.GC18316@pox.localdomain>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
 <1444281803-24274-2-git-send-email-ast@plumgrid.com>
 <1444328452.3935641.405110585.76554E06@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1444328452.3935641.405110585.76554E06-2RFepEojUI2N1INw9kWLP6GC3tUn3ZHUQQ4Iyu8u01E@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/08/15 at 08:20pm, Hannes Frederic Sowa wrote:
> Hi Alexei,
> 
> On Thu, Oct 8, 2015, at 07:23, Alexei Starovoitov wrote:
> > The feature is controlled by sysctl kernel.unprivileged_bpf_disabled.
> > This toggle defaults to off (0), but can be set true (1).  Once true,
> > bpf programs and maps cannot be accessed from unprivileged process,
> > and the toggle cannot be set back to false.
> 
> This approach seems fine to me.
> 
> I am wondering if it makes sense to somehow allow ebpf access per
> namespace? I currently have no idea how that could work and on which
> namespace type to depend or going with a prctl or even cgroup maybe. The
> rationale behind this is, that maybe some namespaces like openstack
> router namespaces could make usage of advanced ebpf capabilities in the
> kernel, while other namespaces, especially where untrusted third parties
> are hosted, shouldn't have access to those facilities.
> 
> In that way, hosters would be able to e.g. deploy more efficient
> performance monitoring container (which should still need not to run as
> root) while the majority of the users has no access to that. Or think
> about routing instances in some namespaces, etc. etc.

The standard way of granting privileges like this for containers is
through CAP_ which does seem like a good fit for this as well and would
also solve your mentioned openstack use case.
