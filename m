From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Thu, 09 Apr 2015 07:02:52 -0400
Message-ID: <55265C5C.7020200@mojatatu.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net> <5525EC69.1080606@plumgrid.com> <5526593E.4040608@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:36169 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754967AbbDILC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 07:02:56 -0400
Received: by iebrs15 with SMTP id rs15so97426188ieb.3
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 04:02:55 -0700 (PDT)
In-Reply-To: <5526593E.4040608@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/15 06:49, Jamal Hadi Salim wrote:
> On 04/08/15 23:05, Alexei Starovoitov wrote:
> [..]
>> As I said I'd rather disable them attaching to ingress than force
>> all program authors to always use network_offset.
>> Offset 0 points to L2 was always fundamental assumption of BPF.
>
> The issue is not really the ingress qdisc here - rather the ingress
> qdisc tries to cope with _how things work_.
> The challenge is *some netdevs* (not all) strip off the link
> layer _before_ the ingres qdisc sees them. You have to recognize
> those devices and only speacial case with them. Your assumptions of
> blindly pushing/pulling will break  in some cases (take a look at
> mirred).
>

To be precise look at:
tcf_mirred_init() and how ok_push based on dev->type is decided.
So we do this in the slow path and make a simple compare in the
fast path on whether push the l2 header.

cheers,
jamal
