From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH iproute2 -next] tc,
 bpf: finalize eBPF support for cls and act front-end
Date: Thu, 02 Apr 2015 02:13:56 +0200
Message-ID: <1427933636.1888890.248325033.0A76BE0D@webmail.messagingengine.com>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, tgraf@suug.ch,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60616 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752536AbbDBAN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 20:13:57 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 93FC820716
	for <netdev@vger.kernel.org>; Wed,  1 Apr 2015 20:13:53 -0400 (EDT)
In-Reply-To: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Tue, Mar 31, 2015, at 00:35, Daniel Borkmann wrote:
> This work finalizes both eBPF front-ends for the classifier and action
> part in tc, it allows for custom ELF section selection, a simplified tc
> command frontend (while keeping compat), reusing of common maps between
> classifier and actions residing in the same object file, and exporting
> of all map fds to an eBPF agent for handing off further control in user
> space.
> 
> It also adds an extensive example of how eBPF can be used, and a minimal
> self-contained example agent that dumps map data. The example is well
> documented and hopefully provides a good starting point into programming
> cls_bpf and act_bpf.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>

(I talked to Daniel about this already but maybe just to get more people
involved on how to handle maps in future, my yet unfinished proposal)

I think this is going into the right direction.

In the end I would also love to see a way to interactively query/update
the bpf maps. I think not a lot would be needed to do that:

Maybe a small utility programs like:

bpf (--lookup|--update|--delete|--get-next-key) -fd
filedescriptor-number (type conversion parameters here) key [value]

So it can be easily used by shell scripts.

For that the filedescriptor numbers would need to be exported (already
opened) into a spawned shell and the numbers could be specified either
in environment or just by printing text which can be sourced by shells
(we already talked about the maybe exec 5</proc/pid/fd/1234 idea). Seems
this can be just build ontop this current patch by extending the
bpf-agent you already build, no?

Otherwise, may I suggest to give C-files which should be used by llvm
--emit bpf another file extension, like .ebpf (or put together some
initials :) )?

Nice work! Thanks!
Hannes
