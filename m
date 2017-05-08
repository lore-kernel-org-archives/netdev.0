From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH/RFC net-next v2 1/4] flow dissector: return error on port
 dissection under-run
Date: Mon, 8 May 2017 07:21:01 -0400
Message-ID: <6fff0cd9-3de3-194f-4620-4081a767b59f@mojatatu.com>
References: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
 <1493988426-22854-2-git-send-email-simon.horman@netronome.com>
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
Received: from mail-io0-f193.google.com ([209.85.223.193]:33685 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754317AbdEHLVE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 07:21:04 -0400
Received: by mail-io0-f193.google.com with SMTP id l196so8596734ioe.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 04:21:04 -0700 (PDT)
In-Reply-To: <1493988426-22854-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-05 08:47 AM, Simon Horman wrote:
> Return an error from __skb_flow_dissect() if insufficient packet data is
> present when dissecting layer 4 ports.
>
> Without this patch the absence of ports in truncated - e.g. UDP - packets
> is treated the same way by the flow dissector as the presence of ports with
> a value of zero. And without this patch the flower classifier is unable to
> differentiate between these two cases which may lead to unexpected matching
> of truncated packets.
>
> With this patch the flow dissector and in turn the flower classifier can
> differentiate between packets with zero L4 ports and truncated packets.
>
> The approach taken here is to only return an error if the offset of ports
> for the previously dissected IP protocol is known - a non error return from
> proto_ports_offset() - but port data is not present in the packet - an
> error return value from __skb_header_pointer().
>
> The behaviour for callers of __skb_flow_get_ports() is changed but the only
> callers are skb_flow_get_ports() and the flow dissector.  The former has
> been updated so that its behaviour is unchanged.  Behavioural change of the
> latter is the intended purpose of this patch but will only take effect with
> a separate patch to have it refuse to match if dissection fails.
>
> This change will lead to behavioural changes of the users of the dissector
> with FLOW_DISSECTOR_KEY_PORTS - flower, and users of
> flow_keys_dissector_keys[] and flow_keys_dissector_symmetric_keys[].  The
> behavioural change for *_keys[] changes seem reasonable as the change will
> should only be for truncated packets.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>

Reviewed-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
