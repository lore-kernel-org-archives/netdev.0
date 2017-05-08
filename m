From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH/RFC net-next v2 4/4] net/sched: cls_flower: allow control
 of tree traversal on packet parse errors
Date: Mon, 8 May 2017 07:32:02 -0400
Message-ID: <6c618cf6-99ec-d2e1-f1ed-dfae0bf54de7@mojatatu.com>
References: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
 <1493988426-22854-5-git-send-email-simon.horman@netronome.com>
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
Received: from mail-it0-f52.google.com ([209.85.214.52]:37443 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752105AbdEHLcF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 07:32:05 -0400
Received: by mail-it0-f52.google.com with SMTP id x188so36157554itb.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 04:32:05 -0700 (PDT)
In-Reply-To: <1493988426-22854-5-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-05 08:47 AM, Simon Horman wrote:
> Allow control how the tree of qdisc, classes and filters is further
> traversed if an error is encountered when parsing the packet in order to
> match the cls_flower filters at a particular prio.
>
> By default continue to the next filter, the behaviour without this patch.
>
> A use-case for this is to allow configuration of dropping of packets with
> truncated headers.
>
> For example, the following drops IPv4 packets that cannot be parsed by the
> flow dissector up to the end of the UDP ports - e.g. because they are
> truncated, and instantiates a continue action based on the port for packets
> that can be parsed.
>
>  # tc qdisc del dev eth0 ingress; tc qdisc add dev eth0 ingress
>  # tc filter add dev eth0 protocol ip parent ffff: flower \
>        indev eth0 ip_proto udp dst_port 80 truncated drop action continue
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>

I agree with Cong on this. The default should be "didnt match" (which
is accomplished by returning -1). The user could enter an explicit
rule to override this behavior. i.e something like:

tc filter add dev eth0 protocol ip parent ffff: flower \
         indev eth0 ip_proto udp dst_port 80 truncated action continue

cheers,
jamal
