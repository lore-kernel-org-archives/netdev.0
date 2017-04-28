From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next 0/4] net/sched: cls_flower: avoid false
 matching of truncated packets
Date: Fri, 28 Apr 2017 15:11:56 +0200
Message-ID: <20170428131155.GA30329@vergenet.net>
References: <20170428120035.15984-1-simon.horman@netronome.com>
 <422d55da-f861-1bc6-983d-199fc383c113@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36878 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423436AbdD1NL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 09:11:59 -0400
Received: by mail-wm0-f51.google.com with SMTP id m123so46413281wma.0
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 06:11:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <422d55da-f861-1bc6-983d-199fc383c113@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 28, 2017 at 08:52:56AM -0400, Jamal Hadi Salim wrote:
> On 17-04-28 08:00 AM, Simon Horman wrote:
> >Hi,
> >
> >this series is intended to avoid false-positives which match
> >truncated packets against flower classifiers which match on:
> >* zero L4 ports or;
> >* zero ICMP code or type
> >
> >This requires updating the flow dissector to return an error in such cases
> >and updating flower to not match on the result of a failed dissection.
> >
> >In the case of UDP this results in a behavioural change to users of
> >flow_keys_dissector_keys[] and flow_keys_dissector_symmetric_keys[] -
> >dissection will fail on truncated packets where the IP protocol of the
> >packets indicates ports should be present (according to skb_flow_get_ports()).
> 
> I think i understand the use case/need.
> But would it be fair to say that the truncated vs non-truncated are two
> different filter rules?

How would you describe such a rule? The case that is being dealt with is
one where there is a parse error and thus nothing to match on from a flower
pov.

> Example what would offloading of
> header_parse_err_action mean?

Why would it need to differ semantically to the implementation in this
patch? I feel that I am missing something.
