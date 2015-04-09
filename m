From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Thu, 09 Apr 2015 06:49:34 -0400
Message-ID: <5526593E.4040608@mojatatu.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net> <5525EC69.1080606@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:33401 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932671AbbDIKtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 06:49:42 -0400
Received: by iebmp1 with SMTP id mp1so97224355ieb.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 03:49:42 -0700 (PDT)
In-Reply-To: <5525EC69.1080606@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/15 23:05, Alexei Starovoitov wrote:
[..]
> As I said I'd rather disable them attaching to ingress than force
> all program authors to always use network_offset.
> Offset 0 points to L2 was always fundamental assumption of BPF.

The issue is not really the ingress qdisc here - rather the ingress
qdisc tries to cope with _how things work_.
The challenge is *some netdevs* (not all) strip off the link
layer _before_ the ingres qdisc sees them. You have to recognize
those devices and only speacial case with them. Your assumptions of
blindly pushing/pulling will break  in some cases (take a look at
mirred).

Having said that:
why could you not use the AT bits to identify whether you are
being invoked at ingress in the ebpf cls/ac wrapper? IOW:
have bpf cls/act be responsible for that knowledge.
Your changes penalize everyone else because of this assumption
bpf makes. We have always tried to be sensitive to perfomance.
People like Eric D. complain about a single if statement in this
code path and you are adding a bunch more unconditionally.
If all i wanted to do was police or account (a good number of use
cases) suddenly this gets more costly.

cheers,
jamal
