From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next RFC 0/6] Configure cloud filters in i40e via
 tc/flower classifier
Date: Tue, 1 Aug 2017 06:15:22 -0400
Message-ID: <2d833571-a5f3-41a6-0e6c-9d2c27b0a8c5@mojatatu.com>
References: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com,
        Or Gerlitz <gerlitz.or@gmail.com>
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34711 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbdHAKPZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:15:25 -0400
Received: by mail-io0-f194.google.com with SMTP id m88so1210357iod.1
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 03:15:25 -0700 (PDT)
In-Reply-To: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-31 08:36 PM, Amritha Nambiar wrote:
> This patch series enables configuring cloud filters in i40e
> using the tc/flower classifier. The only tc-filter action
> supported is to redirect packets to a traffic class on the
> same device. The tc/mirred:redirect action is extended to
> accept a traffic class to achieve this.
> 
> The cloud filters are added for a VSI and are cleaned up when
> the VSI is deleted. The filters that match on L4 ports needs
> enhanced admin queue functions with big buffer support for
> extended general fields in Add/Remove Cloud filters command.
> 
> Example:
> # tc qdisc add dev eth0 ingress
> 
> # ethtool -K eth0 hw-tc-offload on
> 
> # tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
>    dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
>    skip_sw indev eth0 action mirred ingress redirect dev eth0 tc 1
> 

I think "queue 1" sounds better than "tc 1".
"tc" is  already a keyword in a few places (even within that declaration
above).

cheers,
jamal
