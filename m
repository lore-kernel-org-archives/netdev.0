From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 1/2] net: cls_bpf: fix size mismatch on filter preparation
Date: Thu, 22 Jan 2015 08:39:59 -0800
Message-ID: <CAADnVQL+Y9avwq4QkJc+hetqCM2=-vhuSTZTEUCE7T8o_4QDng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36804 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbbAVQk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 11:40:26 -0500
Received: by mail-qg0-f41.google.com with SMTP id q108so2041320qgd.0
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 08:40:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 1:41 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> In cls_bpf_modify_existing(), we read out the number of filter blocks,
> do some sanity checks, allocate a block on that size, and copy over the
> BPF instruction blob from user space, then pass everything through the
> classic BPF checker prior to installation of the classifier.
>
> We should reject mismatches here, there are 2 scenarios: the number of
> filter blocks could be smaller than the provided instruction blob, so
> we do a partial copy of the BPF program, and thus the instructions will
> either be rejected from the verifier or a valid BPF program will be run;
> in the other case, we'll end up copying more than we're supposed to,
> and most likely the trailing garbage will be rejected by the verifier
> as well (i.e. we need to fit instruction pattern, ret {A,K} needs to be
> last instruction, load/stores must be correct, etc); in case not, we
> would leak memory when dumping back instruction patterns. The code should
> have only used nla_len() as Dave noted to avoid this from the beginning.
> Anyway, lets fix it by rejecting such load attempts.
>
> Fixes: 7d1d65cb84e1 ("net: sched: cls_bpf: add BPF-based classifier")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
