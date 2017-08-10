From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master] bpf: unbreak libelf linkage for bpf obj
 loader
Date: Thu, 10 Aug 2017 16:41:31 -0700
Message-ID: <20170810164131.3bf0ef89@xeon-e3>
References: <8ddcce8a9564e9c4a265db790002d6cd5ba8f353.1502316870.git.daniel@iogearbox.net>
        <20170809173512.2db1eb40@xeon-e3>
        <598C1CDD.3090604@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36830 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdHJXlj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 19:41:39 -0400
Received: by mail-pg0-f49.google.com with SMTP id v77so8741536pgb.3
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 16:41:38 -0700 (PDT)
In-Reply-To: <598C1CDD.3090604@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Aug 2017 10:44:13 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 08/10/2017 02:35 AM, Stephen Hemminger wrote:
> > On Thu, 10 Aug 2017 00:15:41 +0200
> > Daniel Borkmann <daniel@iogearbox.net> wrote:
> >  
> >> Commit 69fed534a533 ("change how Config is used in Makefile's") moved
> >> HAVE_MNL specific CFLAGS/LDLIBS for building with libmnl out of the
> >> top level Makefile into sub-Makefiles. However, it also removed the
> >> HAVE_ELF specific CFLAGS/LDLIBS entirely, which breaks the BPF object
> >> loader for tc and ip with "No ELF library support compiled in." despite
> >> having libelf detected in configure script. Fix it similarly as in
> >> 69fed534a533 for HAVE_ELF.
> >>
> >> Fixes: 69fed534a533 ("change how Config is used in Makefile's")
> >> Reported-by: Jeffrey Panneman <jeffrey.panneman@tno.nl>
> >> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>  
> >
> > Thanks, but I am thinking maybe a better solution long term would be to
> > move all the package specific stuff into the generated Config file.
> >
> > That way only the generation shell script would have to change.
> >
> > Also, all the flags should probably be using pkg-config to get the values.  
> 
> Sure, sounds all good, for the time being, I would like to have
> that breakage undone though, so users can work with loading BPF
> programs again on -master.
> 
> Thanks,
> Daniel

Agree. I will merge this for master, and work on better config management
in net-next.
