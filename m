From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH/RFC net-next 0/4] net/sched: cls_flower: avoid false
 matching of truncated packets
Date: Fri, 28 Apr 2017 08:52:56 -0400
Message-ID: <422d55da-f861-1bc6-983d-199fc383c113@mojatatu.com>
References: <20170428120035.15984-1-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:37149 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425870AbdD1Mw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 08:52:59 -0400
Received: by mail-it0-f52.google.com with SMTP id x188so36179340itb.0
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 05:52:59 -0700 (PDT)
In-Reply-To: <20170428120035.15984-1-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-28 08:00 AM, Simon Horman wrote:
> Hi,
>
> this series is intended to avoid false-positives which match
> truncated packets against flower classifiers which match on:
> * zero L4 ports or;
> * zero ICMP code or type
>
> This requires updating the flow dissector to return an error in such cases
> and updating flower to not match on the result of a failed dissection.
>
> In the case of UDP this results in a behavioural change to users of
> flow_keys_dissector_keys[] and flow_keys_dissector_symmetric_keys[] -
> dissection will fail on truncated packets where the IP protocol of the
> packets indicates ports should be present (according to skb_flow_get_ports()).

I think i understand the use case/need.
But would it be fair to say that the truncated vs non-truncated are two
different filter rules? Example what would offloading of 
header_parse_err_action mean?

cheers,
jamal
