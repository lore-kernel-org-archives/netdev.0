From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [net-next 0/2] BPF, kprobes: Add current_in_cgroup helper
Date: Sat, 6 Aug 2016 21:56:06 -0700
Message-ID: <20160807045605.GA10067@ircssh.c.rugged-nimbus-611.internal>
References: <20160807040651.GA9262@ircssh.c.rugged-nimbus-611.internal>
 <20160807043203.GA77894@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:35533 "EHLO
	mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbcHGE4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 00:56:09 -0400
Received: by mail-it0-f49.google.com with SMTP id u186so51525582ita.0
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2016 21:56:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160807043203.GA77894@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 06, 2016 at 09:32:05PM -0700, Alexei Starovoitov wrote:
> On Sat, Aug 06, 2016 at 09:06:53PM -0700, Sargun Dhillon wrote:
> > This patchset includes a helper and an example to determine whether the kprobe 
> > is currently executing in the context of a specific cgroup based on a cgroup
> > bpf map / array. 
> 
> description is too short to understand how this new helper is going to be used.
> depending on kprobe current is not always valid.
Anything not in in_interrupt() should have a current, right?

> what are you trying to achieve?
This is primarily to help troubleshoot containers (Docker, and now systemd). A 
lot of the time we want to determine what's going on in a given container 
(opening files, connecting to systems, etc...). There's not really a great way 
to restrict to containers except by manually walking datastructures to check for 
the right cgroup. This seems like a better alternative.

> This looks like an alternative to lsm patches submitted earlier?
No. But I would like to use this helper in the LSM patches I'm working on. For 
now, with those patches, and this helper, I can create a map sized 1, and add 
the cgroup I care about to it. Given I can add as many bpf programs to an LSM
hook I want, I can use this mechanism to "attach BPF programs to cgroups" -- 
I put that in quotes because you're not really attaching it to a cgroup,
but just burning some instructions on checking it. 

In my mind it seems better than making cgroup-attachment a first-class part
of the checmate work since I still want to make globally available hooks
possible.

> btw net-next is closed and no new features accepted at the moment.
Sorry, I didn't realize that. I'd still love to get feedback.
> 
