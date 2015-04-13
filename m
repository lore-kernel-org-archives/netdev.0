From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Mon, 13 Apr 2015 09:13:18 -0700
Message-ID: <552BEB1E.2060704@plumgrid.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net> <5525EC69.1080606@plumgrid.com> <5526593E.4040608@mojatatu.com> <5526B0E0.7060000@plumgrid.com> <5527C6AE.6010301@mojatatu.com> <55285038.3060806@plumgrid.com> <552BD2A8.10105@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:36039 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932175AbbDMQNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 12:13:21 -0400
Received: by iebrs15 with SMTP id rs15so68897709ieb.3
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 09:13:20 -0700 (PDT)
In-Reply-To: <552BD2A8.10105@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/15 7:28 AM, Jamal Hadi Salim wrote:
> On 04/10/15 18:35, Alexei Starovoitov wrote:
>
>>> To your "bugs" comments:
>>> - updating csum; earlier i said i was conflicted it being a
>>> useful "feature".
>>> You are repeating again that it is a bug. It is not.
>>> This action is intended to  mirror or redirect packets, period.
>>
>> without updating skb->csum act_mirred is breaking csum for
>> checksum_complete devices.
>
> Ok, could this then be checked for in dev features flags and
> only then recomputed?

that's what my v2 patch did :)
if ip_summed == checksum_complete -> recompute skb->csum

> Yes, I see your point here as reasonable dilema. But you could add an
> API call the user always make that resets and unsets the header?
> It would be a single branch failure for egress/stack source.

cannot do that from the program. skb->data and headerlen are already
cached by JITs and skb pointer itself is in some bpf registers,
so push/pull/skb_share_check is _not_ possible when program is running.
It can only be done before program starts. That's exactly what all my
patches are doing.
