From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Wed, 26 Oct 2016 09:44:16 -0600
Message-ID: <a7550e57-bbe3-af38-22d8-77f7c73bf879@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
 <580FEA98.1090809@iogearbox.net>
 <660435c4-6cea-9648-0106-afb3ab6910fc@cumulusnetworks.com>
 <58106A72.4050306@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@zonque.org, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32771 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932692AbcJZPoT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 11:44:19 -0400
Received: by mail-pf0-f169.google.com with SMTP id 197so17764971pfu.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 08:44:19 -0700 (PDT)
In-Reply-To: <58106A72.4050306@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/16 2:33 AM, Daniel Borkmann wrote:
> Sure, I understand that, and I know it was brought up at netconf, I'm
> just still wondering in general if BPF is a good fit here in the sense
> that what the program can do is just really really limited (at least
> right now). Hmm, just trying to understand where this would go long term.
> Probably okay'ish, if it's guaranteed that it can also integrate various
> other use cases as well for the new program type like the ones proposed
> by Anoop from net cgroup.
> 
> If that would reuse BPF_PROG_TYPE_CGROUP_SOCK from not only sk_alloc()
> hook, programs can thus change sk_bound_dev_if also from elsewhere since
> it's a fixed part of the context, and attaching to the cgroup comes after
> program was verified and returned a program fd back to the user. I guess
> it might be expected, right?

sure.

> 
> I mean non-cooperative processes in that cgroup could already overwrite
> the policy set in sk_alloc() anyway with SO_BINDTODEVICE, no? What is the

yes. If a process running as root is invoked/wants to change the binding it can. For example a shell is set in Management VRF context and the user wants to ping out a data plane port the -I arg would do that.

> expectation if processes are moved from one cgroup to another one? Is it 
> expected that also sk_bound_dev_if updates (not yet seeing how that would
> work from a BPF program)? If sk_bound_dev_if is enforced from cgroup side,
> should that lock out processes from changing it (maybe similar to what we
> do in SOCK_FILTER_LOCKED)?

existing sockets would not be affected by the cgroup program.
