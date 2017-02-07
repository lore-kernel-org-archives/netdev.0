From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/4] Documenting eBPF - extended Berkeley Packet
 Filter
Date: Tue, 07 Feb 2017 17:43:38 +0100
Message-ID: <5899F93A.70708@iogearbox.net>
References: <148647756092.10567.10947541548678801938.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, alexander@alemayhu.com,
        linux-kernel@vger.kernel.org, quentin.monnet@6wind.com,
        Daniel Borkmann <borkmann@iogearbox.net>, mtk@man7.org
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148647756092.10567.10947541548678801938.stgit@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jesper,

On 02/07/2017 03:30 PM, Jesper Dangaard Brouer wrote:
> Question: What kernel tree should this go into???
>
> If going through Jonathan Corbet, will it appear sooner here???
>   https://www.kernel.org/doc/html/latest/
> If it will not appear sooner that way, then it's likely best to keep
> it in sync with the tree that takes eBPF code changes.

For initial parts, I don't have a preference (Jonathan has though,
so seems fine via docs tree then). If at some /later/ point in time
features come in along with doc updates (similar to test case updates),
probably best to route them via net-next.

> This marks the beginning of user-facing developer documentation for
> using eBPF (extended Berkeley Packet Filter) as part of the kernel
> Documentation/ tree.
>
> This documentation is also available here[1], as an intermidiate quick
> way of prototyping and releasing the documentation.  The autoriative
> and official version of the documentation is what gets included in the
> kernel tree.  The docs at [2] will get updated based on what gets
> accepted after the standard peer-review kernel process.

Thanks for your effort of writing a doc. Some high-level comments on
the set from my PoV first.

I think it's definitely the right direction to move everything BPF
related to Documentation/BPF/. Right now, there are a lot of different
places with different kind of documentation, f.e.:

* Documentation/networking/filter.txt
   Covers some cBPF/eBPF internals, tooling, etc; mostly technical,
   historically the central spot for BPF documentation. "filter" in
   filter.txt is long obsolete name, but looks like various sites,
   talks, blogs, etc still link to it. (At best, we should keep the
   file saying that the doc moved to Documentation/BPF/.)

* bpf(2) man page
   Has a good start, but right now is heavily behind the current user
   facing kernel code.

* include/uapi/linux/bpf.h
   Mostly relevant for helper function API description.

* netdev conference slides/proceedings
   Also contain mostly technical details on eBPF.

* https://github.com/iovisor/bpf-docs
   Non-exhaustive collection of various talks from different confs.

* https://qmonnet.github.io/whirl-offload/2016/09/01/dive-into-bpf/
   Even bigger and more complete list of documentation material.

* Various lwn articles ;), blog posts (f.e. from Brendan), etc.

Now, challenge is to bring the relevant parts together and logically
separated into Documentation/BPF/ and bpf(2) man page. I think everything
user API relevant would help most if it updates bpf(2) man page. That can
be explanation of different map types, interaction with maps, quirks, etc.

Eventually also helper functions. Right now they're all documented in
include/uapi/linux/bpf.h and that's okay as it ships along with the
kernel code, so they're in sync. Eventually, there should be some more
elaborate description of them, perhaps with tiny examples, in bpf(2)
as well, since it's part of the uapi and stable (helpers themselves at
least).

The Documentation/networking/filter.txt would need to be reworked a
bit and split into pieces for Documentation/BPF/, so we keep that as a
central place for the technical parts. Documentation/RCU/ is doing a
great job at that, and I would like to see Documentation/BPF/ being as
helpful for developers here. Part of that would be to add missing pieces
from the various available sources mentioned above or elsewhere, so
people can get a deeper understanding on internals beyond reading just
man page for the user API description; explaining concepts, etc. Part
of that can also be on the ELF loader bits, etc, no doubt.

On a quick glance on the remaining patches, it seems a mixture of quotes
from the bpf(2) man page, filter.txt along with sample code explanation and
lots of external links, part of them to https://git.kernel.org/cgit/linux/...,
http://lxr.free-electrons.com, http://man7.org, http://www.slideshare.net/,
https://github.com/torvalds/linux/..., etc. I would suggest that instead we
should make Documentation/BPF/ eventually as self-contained as possible
and the central place for the internals where others link to instead. It
might take a bit, but I think definitely worth it.

Regarding patches, could you split the parts that should go to bpf(2) off
and submit them to man page tree for inclusion? I think that would be
incredibly helpful. And the remaining internals to start a Documentation/BPF/
directory, even if initially just small (but will grow over time of
course)?

Thanks,
Daniel

> [1] http://prototype-kernel.readthedocs.io/en/latest/bpf/index.html
> [2] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/Documentation
>
> Thanks to the following people, who have already reviewed and fixed
> earlier versions of this documentation on the IOvisor mailing-list:
>
>   Alexander Alemayhu <alexander@alemayhu.com>
>   Alexei Starovoitov <ast@fb.com>
>   Daniel Borkmann <daniel@iogearbox.net>
>   Quentin Monnet <quentin.monnet@6wind.com>
>
>
> ---
>
> Jesper Dangaard Brouer (4):
>        doc/bpf: start eBPF documentation tree bpf/
>        doc/bpf: document interacting with eBPF maps
>        doc/bpf: describes the different types of eBPF maps available
>        doc/bpf: describe BCC the BPF Compiler Collection
>
>
>   Documentation/bpf/bcc_tool_chain.rst  |   37 +++++
>   Documentation/bpf/ebpf_maps.rst       |  256 +++++++++++++++++++++++++++++++++
>   Documentation/bpf/ebpf_maps_types.rst |  119 +++++++++++++++
>   Documentation/bpf/index.rst           |   68 +++++++++
>   Documentation/index.rst               |    1
>   5 files changed, 481 insertions(+)
>   create mode 100644 Documentation/bpf/bcc_tool_chain.rst
>   create mode 100644 Documentation/bpf/ebpf_maps.rst
>   create mode 100644 Documentation/bpf/ebpf_maps_types.rst
>   create mode 100644 Documentation/bpf/index.rst
>
> --
>
