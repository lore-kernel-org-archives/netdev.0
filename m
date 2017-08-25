From: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Subject: Re: Permissions for eBPF objects
Date: Fri, 25 Aug 2017 15:26:39 -0400
Message-ID: <1503689199.9977.4.camel@tycho.nsa.gov>
References: <CABXk95AiYO7D8o79TBdt0_0g1TXfULSpL5i7KzHF3R4i-WhwHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Jeffrey Vander Stoep <jeffv-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Chenbo Feng <fengc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, SELinux <Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
In-Reply-To: <CABXk95AiYO7D8o79TBdt0_0g1TXfULSpL5i7KzHF3R4i-WhwHw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, 2017-08-25 at 11:01 -0700, Jeffrey Vander Stoep via Selinux
wrote:
> I’d like to get your thoughts on adding LSM permission checks on BPF
> objects.
> 
> By default, the ability to create and use eBPF maps/programs requires
> CAP_SYS_ADMIN [1]. Alternatively, all processes can be granted access
> to bpf() functions. This seems like poor granularity. [2]
> 
> Like files and sockets, eBPF maps and programs can be passed between
> processes by FD and have a number of functions that map cleanly to
> permissions.
> 
> Let me know what you think. Are there simpler alternative approaches
> that we haven’t considered?

Is it possible to create the map/program in one process (with
CAP_SYS_ADMIN), pass the resulting fd to netd, and then use it there
(without requiring CAP_SYS_ADMIN in netd itself)?

What level of granularity would be useful?  Would it go beyond just
being able to use bpf() at all?

> 
> Thanks!
> Jeff
> 
> [1] http://man7.org/linux/man-pages/man2/bpf.2.html NOTES section
> [2] We are considering eBPF for network filtering by netd. Giving
> netd
> CAP_SYS_ADMIN would considerably increase netd’s privileges.
> Alternatively allowing all processes permission to use bpf() goes
> against the principle of least privilege exposing a lot of kernel
> attack surface to processes that do not actually need it.
> 
