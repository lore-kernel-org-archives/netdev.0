From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Permissions for eBPF objects
Date: Fri, 25 Aug 2017 13:04:10 -0700
Message-ID: <57ba5574-6103-b7c1-8813-c708b6d613be@schaufler-ca.com>
References: <CABXk95AiYO7D8o79TBdt0_0g1TXfULSpL5i7KzHF3R4i-WhwHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Jeffrey Vander Stoep <jeffv@google.com>,
        Chenbo Feng <fengc@google.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        LSM <linux-security-module@vger.kernel.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CABXk95AiYO7D8o79TBdt0_0g1TXfULSpL5i7KzHF3R4i-WhwHw@mail.gmail.com>
Content-Language: en-US
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding the LSM list to the thread.

On 8/25/2017 11:01 AM, Jeffrey Vander Stoep via Selinux wrote:
> I’d like to get your thoughts on adding LSM permission checks on BPF objects.

Aside from the use of these objects requiring privilege,
what sort of controls do you think might be reasonable?
Who "owns" these objects? Can you have a coherent system
if one entity changes maps and another changes programs?
Why would "finer granularity" be better?

While I understand the issues with CAP_SYS_ADMIN being
uncomfortably general I am not the advocate of fine
grained controls that many of my peers and betters are.
Would the increased complexity add value? How?

> By default, the ability to create and use eBPF maps/programs requires
> CAP_SYS_ADMIN [1]. Alternatively, all processes can be granted access
> to bpf() functions. This seems like poor granularity. [2]

You could put mode bits on your maps, programs, functions.
Do you otherwise treat these as objects, or are the more
like process state?


> Like files and sockets, eBPF maps and programs can be passed between
> processes by FD and have a number of functions that map cleanly to
> permissions.
>
> Let me know what you think. Are there simpler alternative approaches
> that we haven’t considered?
>
> Thanks!
> Jeff
>
> [1] http://man7.org/linux/man-pages/man2/bpf.2.html NOTES section
> [2] We are considering eBPF for network filtering by netd. Giving netd
> CAP_SYS_ADMIN would considerably increase netd’s privileges.
> Alternatively allowing all processes permission to use bpf() goes
> against the principle of least privilege exposing a lot of kernel
> attack surface to processes that do not actually need it.

Just thinking out loud here, but if there is ownership on your
"objects" (objects have names, owners and access controls)
you could let the owner decide who gets to use them, just like
you do with user-space programs. This is kind of iffy for
programs that execute in the kernel, but you're already putting
a lot of trust in the eBPF implementation.

The big thing you need to do is define a security model, with
a list of subjects, objects and accesses. Once you have that
coming up with a basic access control policy is a matter of
creating something Linux-ish. The security modules will follow
on with their own interpretations of how to make it even better
in due course.

