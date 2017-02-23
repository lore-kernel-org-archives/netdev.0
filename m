From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v5] bpf: add helper to compare network namespaces
Date: Wed, 22 Feb 2017 20:28:47 -0700
Message-ID: <1a4f1938-6f2a-2c75-d45a-41c46baac039@cumulusnetworks.com>
References: <1487208564-4666-1-git-send-email-dsa@cumulusnetworks.com>
 <58A57A13.9070906@iogearbox.net> <878tp1h4xs.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ast@kernel.org,
        tj@kernel.org, luto@amacapital.net
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33695 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdBWD2u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 22:28:50 -0500
Received: by mail-pg0-f52.google.com with SMTP id z128so9341587pgb.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 19:28:50 -0800 (PST)
In-Reply-To: <878tp1h4xs.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/19/17 9:17 PM, Eric W. Biederman wrote:
>>> @@ -2597,6 +2598,39 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
>>>   	.arg5_type	= ARG_CONST_STACK_SIZE,
>>>   };
>>>
>>> +BPF_CALL_3(bpf_sk_netns_cmp, struct sock *, sk,  u64, ns_dev, u64, ns_ino)
>>> +{
>>> +	return netns_cmp(sock_net(sk), ns_dev, ns_ino);
>>> +}
>>
>> Is there anything that speaks against doing the comparison itself
>> outside of the helper? Meaning, the helper would get a buffer
>> passed from stack f.e. struct foo { u64 ns_dev; u64 ns_ino; }
>> and fills both out with the netns info belonging to the sk/skb.
> 
> Yes.  The dev/ino pair is not necessarily unique so it is not at all
> clear that the returned value would be what the program is expecting.

How does the comparison inside a helper change the fact that a dev and
inode number are compared? ie., inside or outside of a helper, the end
result is that a bpf program has a dev/inode pair that is compared to
that of a socket or skb.

Ideally, it would be nice to have a bpf equivalent to net_eq(), but it
is not possible from a practical perspective to have bpf programs load a
namespace reference (address really) from a given pid or fd.
