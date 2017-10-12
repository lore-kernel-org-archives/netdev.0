From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 01/12] bpf: verifier: set reg_type on context
 accesses in second pass
Date: Thu, 12 Oct 2017 14:39:50 -0700
Message-ID: <20171012143950.58c1b601@cakuba.netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
        <20171012173418.4029-2-jakub.kicinski@netronome.com>
        <59DFD3DE.9050907@iogearbox.net>
        <20171012135632.1fa408bc@cakuba.netronome.com>
        <59DFDFA1.3020809@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:46441 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750990AbdJLVjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 17:39:54 -0400
Received: by mail-qt0-f174.google.com with SMTP id 1so16256702qtn.3
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 14:39:53 -0700 (PDT)
In-Reply-To: <59DFDFA1.3020809@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Oct 2017 23:33:21 +0200, Daniel Borkmann wrote:
> On 10/12/2017 10:56 PM, Jakub Kicinski wrote:
> > On Thu, 12 Oct 2017 22:43:10 +0200, Daniel Borkmann wrote:  
> [...]
> >> It would be nice to keep the reg_type setting in one place, meaning
> >> the callbacks themselves, so we wouldn't need to maintain this in
> >> multiple places.  
> >
> > Hm.. I though this was the smallest and simplest change.  I could
> > translate the offsets but that seems wobbly.  Or try to consolidate the
> > call into the same if () branch?  Not sure..  
> 
> Different callbacks for post-verification would be good at min as it
> would allow to keep all the context access info in one place for a
> given type at least.

Sorry to be clear - you're suggesting adding a new callback to struct
bpf_verifier_ops, or swapping the struct bpf_verifier_ops for a
special post-verification one?

> > As a bonus info I discovered there is a bug in -net with how things are
> > converted.  We allow arithmetic on context pointers but then only
> > look at the insn.off in the converter...  I'm working on a fix.  
> 
> Ohh well, good catch, indeed! :( Can you also add coverage to the
> bpf selftests for this?

Will do!
