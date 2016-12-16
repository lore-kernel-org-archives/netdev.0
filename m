From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/2] bpf: do not use KMALLOC_SHIFT_MAX
Date: Fri, 16 Dec 2016 15:23:42 -0800
Message-ID: <20161216232340.GA99159@ast-mbp.thefacebook.com>
References: <20161215164722.21586-1-mhocko@kernel.org>
 <20161215164722.21586-2-mhocko@kernel.org>
 <20161216180209.GA77597@ast-mbp.thefacebook.com>
 <20161216220235.GD7645@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, Cristopher Lameter <cl@linux.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: Michal Hocko <mhocko@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33428 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758550AbcLPXXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 18:23:46 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so11070205pgd.0
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 15:23:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161216220235.GD7645@dhcp22.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2016 at 11:02:35PM +0100, Michal Hocko wrote:
> On Fri 16-12-16 10:02:10, Alexei Starovoitov wrote:
> > On Thu, Dec 15, 2016 at 05:47:21PM +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > 01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
> > > overflow") has added checks for the maximum allocateable size. It
> > > (ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
> > > it is not very clean because we already have KMALLOC_MAX_SIZE for this
> > > very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.
> > > 
> > > Cc: Alexei Starovoitov <ast@kernel.org>
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > 
> > Nack until the patches 1 and 2 are reversed.
> 
> I do not insist on ordering. The thing is that it shouldn't matter all
> that much. Or are you worried about bisectability?

This patch 1 strongly depends on patch 2 !
Therefore order matters.
The patch 1 by itself is broken.
The commit log is saying
'(ab)used KMALLOC_SHIFT_MAX for that purpose .. use KMALLOC_MAX_SIZE instead'
that is also incorrect. We cannot do that until KMALLOC_MAX_SIZE is fixed.
So please change the order and fix the commit log to say that KMALLOC_MAX_SIZE
is actually valid limit now.
