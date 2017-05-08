From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH/RFC net-next v2 2/4] flow dissector: return error on icmp
 dissection under-run
Date: Mon, 8 May 2017 07:21:29 -0400
Message-ID: <f1590e4d-aeba-2f52-bb74-5e905659bcf9@mojatatu.com>
References: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
 <1493988426-22854-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Benjamin LaHaise <benjamin.lahaise@netronome.com>
To: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35654 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752833AbdEHLVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 07:21:32 -0400
Received: by mail-io0-f196.google.com with SMTP id o12so1152858iod.2
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 04:21:31 -0700 (PDT)
In-Reply-To: <1493988426-22854-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-05 08:47 AM, Simon Horman wrote:
> Return an error from __skb_flow_dissect() if insufficient packet data is
> present when dissecting icmp type and code.
>
> Without this patch the absence of the ICMP type and code in truncated
> ICMPv4 or IPVPv6 packets is treated the way same as the presence of a code
> and type of value of zero.  And without this patch the flower classifier is
> unable to differentiate between these two cases which may lead to
> unexpected matching of truncated packets.
>
> With this patch the flow dissector and in turn the flower classifier can
> differentiate between packets with zero ICMP type and code, and truncated
> packets.
>
> The approach taken here is to return an error if the IP protocol indicates
> ICMP but the type and code data is not present in the packet - an error
> return value from __skb_header_pointer().
>
> This should only effect the flower classifier as it is the only user of
> W_DISSECTOR_KEY_ICMP.  The behavioural update for flower only takes effect
> with a separate patch to have it refuse to match if dissection fails.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>

Reviewed-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
