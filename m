From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next] bpf: add helper capable of reading out
 instructions
Date: Tue, 25 Jul 2017 11:20:06 -0700
Message-ID: <20170725112006.261bf04f@cakuba.netronome.com>
References: <20170724212236.21903-2-jakub.kicinski@netronome.com>
        <59777477.7050609@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        oss-drivers@netronome.com, kafai@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32886 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdGYSUN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 14:20:13 -0400
Received: by mail-pf0-f171.google.com with SMTP id s70so61396476pfs.0
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 11:20:13 -0700 (PDT)
In-Reply-To: <59777477.7050609@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Jul 2017 18:40:23 +0200, Daniel Borkmann wrote:
> [ +Martin ]

Sorry, I thought I CCed Martin.

> On 07/24/2017 11:22 PM, Jakub Kicinski wrote:
> > To read translated and jited instructions from the kernel,
> > one has to set certain pointers of struct bpf_prog_info to
> > pre-allocated user buffers.  Unfortunately, the existing
> > bpf_obj_get_info_by_fd() helper zeros struct bpf_prog_info
> > before passing it to the kernel.
> >
> > Keeping the zeroing seems like a good idea in general, since
> > kernel will check if the structure was zeroed.  Add a new
> > helper for those more advanced users who can be trusted to
> > take care of zeroing themselves.
> >
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > ---
> > I'm happy to change the name of the new function.
> >
> >   tools/lib/bpf/bpf.c | 10 ++++++++--
> >   tools/lib/bpf/bpf.h |  2 ++
> >   2 files changed, 10 insertions(+), 2 deletions(-)
> >
> > diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
> > index 412a7c82995a..2703fa282b65 100644
> > --- a/tools/lib/bpf/bpf.c
> > +++ b/tools/lib/bpf/bpf.c
> > @@ -308,13 +308,12 @@ int bpf_map_get_fd_by_id(__u32 id)
> >   	return sys_bpf(BPF_MAP_GET_FD_BY_ID, &attr, sizeof(attr));
> >   }
> >
> > -int bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len)
> > +int __bpf_obj_get_info_by_fd(int prog_fd, void *info, __u32 *info_len)
> >   {
> >   	union bpf_attr attr;
> >   	int err;
> >
> >   	bzero(&attr, sizeof(attr));
> > -	bzero(info, *info_len);  
> 
> Looks a bit unintentional to me, e.g. 95b9afd3987f ("bpf: Test for bpf
> ID") did set up pointers in test_bpf_obj_id(), but later only checked
> for the {jited,xlated}_prog_len.
> 
> Clearing out the pointers looks not to useful. Lets just push the need
> for bzero() to call-sites in general in this case.

Should I target this at net then?  To avoid backwards compatibility
issues?
