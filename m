From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 -next] ingress, clsact: don't add TCA_OPTIONS to
 nl msg
Date: Tue, 17 May 2016 07:54:30 -0400
Message-ID: <573B0676.30500@mojatatu.com>
References: <192c686bb5e277b9552fe1e5c39b14bed520dddd.1463329895.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:34235 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbcEQLyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 07:54:39 -0400
Received: by mail-ig0-f195.google.com with SMTP id kj7so1441136igb.1
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 04:54:39 -0700 (PDT)
In-Reply-To: <192c686bb5e277b9552fe1e5c39b14bed520dddd.1463329895.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-15 12:36 PM, Daniel Borkmann wrote:
> In ingress and clsact qdisc TCA_OPTIONS are ignored, since it's
> parameterless. In tc, we add an empty addattr_l(... TCA_OPTIONS,
> NULL, 0) to the netlink message nevertheless. This has the
> side effect that when someone tries a 'tc qdisc replace' and
> already an existing such qdisc is present, tc fails with
> EINVAL here.
>
> Reason is that in the kernel, this invokes qdisc_change() when
> such requested qdisc is already present. When TCA_OPTIONS are
> passed to modify parameters, it looks whether qdisc implements
> .change() callback, and if not present (like in both cases here)
> it returns with error. Rather than adding an empty stub to the
> kernel that ignores TCA_OPTIONS again, just don't add TCA_OPTIONS
> to the netlink message in the first place.
>
> Before:
>
>    # tc qdisc replace dev foo clsact    # first try
>    # tc qdisc replace dev foo clsact    # second one
>    RTNETLINK answers: Invalid argument
>
> After:
>
>    # tc qdisc replace dev foo clsact
>    # tc qdisc replace dev foo clsact
>    # tc qdisc replace dev foo clsact
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

I see need for correctness but was curious of use case
that made you even look at this ;->

cheers,
jamal
