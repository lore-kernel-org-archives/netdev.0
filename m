From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 2/2] net: cls_bpf: fix auto generation of per list handles
Date: Thu, 22 Jan 2015 10:52:20 -0800
Message-ID: <CAADnVQLn2QXJaDvbvothBrKZTnPD1sGjh7ZNPuUG=MH3ZJTU4A@mail.gmail.com>
References: <1421919662-21066-1-git-send-email-dborkman@redhat.com> <1421919662-21066-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:37584 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbbAVSwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 13:52:41 -0500
Received: by mail-qg0-f50.google.com with SMTP id f51so2658205qge.9
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 10:52:40 -0800 (PST)
In-Reply-To: <1421919662-21066-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 1:41 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> When creating a bpf classifier in tc with priority collisions and
> invoking automatic unique handle assignment, cls_bpf_grab_new_handle()
> will return a wrong handle id which in fact is non-unique. Usually
> altering of specific filters is being addressed over major id, but
> in case of collisions we result in a filter chain, where handle ids
> address individual cls_bpf_progs inside the classifier.
>
> Issue is, in cls_bpf_grab_new_handle() we probe for head->hgen handle
> in cls_bpf_get() and in case we found a free handle, we're supposed
> to use exactly head->hgen. In case of insufficient numbers of handles,
> we bail out later as handle id 0 is not allowed.
>
> Fixes: 7d1d65cb84e1 ("net: sched: cls_bpf: add BPF-based classifier")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

interesting bug. first time I'm looking at this bit and wondering
why everyone copy pasting such hgenerator instead of using idr...
