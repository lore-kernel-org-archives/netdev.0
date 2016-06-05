From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net, cls: allow for deleting all filters for
 given parent
Date: Sun, 5 Jun 2016 08:24:33 -0400
Message-ID: <57541A01.909@mojatatu.com>
References: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36828 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbcFEMYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 08:24:41 -0400
Received: by mail-io0-f196.google.com with SMTP id f128so4827382iof.3
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 05:24:41 -0700 (PDT)
In-Reply-To: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-04 12:24 PM, Daniel Borkmann wrote:
> Add a possibility where the user can just specify the parent and
> all filters under that parent are then being purged. Currently,
> for example for scripting, one needs to specify pref/prio to have
> a well-defined number for 'tc filter del' command for addressing
> the previously created instance or additionally filter handle in
> case of priorities being the same. Improve usage by allowing the
> option for tc to specify the parent and removing the whole chain
> for that given parent.
>
> Example usage after patch, no tc changes required:
>
>    # tc qdisc replace dev foo clsact
>    # tc filter add dev foo egress bpf da obj ./bpf.o
>    # tc filter add dev foo egress bpf da obj ./bpf.o
>    # tc filter show dev foo egress
>    filter protocol all pref 49151 bpf
>    filter protocol all pref 49151 bpf handle 0x1 bpf.o:[classifier] direct-action
>    filter protocol all pref 49152 bpf
>    filter protocol all pref 49152 bpf handle 0x1 bpf.o:[classifier] direct-action
>    # tc filter del dev foo egress
>    # tc filter show dev foo egress
>    #
>
> Previously, RTM_DELTFILTER requests with invalid prio of 0 were
> rejected, so only netlink requests with RTM_NEWTFILTER and NLM_F_CREATE
> flag were allowed where the kernel would auto-generate a pref/prio.
> We can piggyback on that and use prio of 0 as a wildcard for
> requests of RTM_DELTFILTER.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>


Looks good to me.
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
