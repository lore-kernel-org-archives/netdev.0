From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH iproute2 -next] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Wed, 1 Apr 2015 23:30:44 +0100
Message-ID: <20150401223044.GB19425@casper.infradead.org>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net>
 <551BE636.7040505@mojatatu.com>
 <551BFD00.1090303@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, stephen@networkplumber.org,
	ast@plumgrid.com, jiri@resnulli.us, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58487 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbbDAWaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 18:30:46 -0400
Content-Disposition: inline
In-Reply-To: <551BFD00.1090303@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/15 at 04:13pm, Daniel Borkmann wrote:
> On 04/01/2015 02:36 PM, Jamal Hadi Salim wrote:
> >On 03/30/15 18:35, Daniel Borkmann wrote:
> >>This work finalizes both eBPF front-ends for the classifier and action
> >>part in tc, it allows for custom ELF section selection, a simplified tc
> >>command frontend (while keeping compat), reusing of common maps between
> >>classifier and actions residing in the same object file, and exporting
> >>of all map fds to an eBPF agent for handing off further control in user
> >>space.
> >>
> >>It also adds an extensive example of how eBPF can be used, and a minimal
> >>self-contained example agent that dumps map data. The example is well
> >>documented and hopefully provides a good starting point into programming
> >>cls_bpf and act_bpf.
> >
> >This is excellent work Daniel.
> 
> Thanks, Jamal! ;)
> 
> [...]
> >I realize you are doing this to illustrate the power of ebpf. And it
> >is impressive. Do you see this as a way to replace pieces of the
> >kernel stack or to aid and abate what the kernel already does?
> 
> I see it as a way to offer a generic, fast and 'safe' option for
> classifier and action developers to have a programmable data path
> in the traffic control subsystem in the kernel, which I think is
> very powerful and important in various use-cases. I regard it as
> a similar way and elegant solution as tcpdump or nftables resolve
> their problems internally, in other words, to provide a _generic_
> solution to address _specific, customized_ issues. Perhaps an anti
> feature-bloat, if you will. ;) My viewpoint is that this ties well
> together into the kernel landscape, and also makes us improve
> various other subsystems that it makes use of, successively.

Alexei will remember that I gave him a hard time with the exact
same remarks as Jamal brought up when he presented this in New
Orleans ;-)

What turned my viewpoint around was the knowledge that function
calls are limited. eBPF programs can only make calls to functions
which have been specifically whitelisted for eBPF programs. This
policy is enforced by the kernel through the verifier. Exported
symbols are not automatically whitelisted. So an eBPF program
can't call into drivers or use arbitrary kernel APIs and is thus
a lot more restricted than a kernel module.
