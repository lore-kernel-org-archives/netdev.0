From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [next-queue v6 PATCH 5/7] i40e: Add TX and RX support over port
 netdev's in switchdev mode
Date: Mon, 3 Apr 2017 11:52:48 -0700
Message-ID: <58E29A00.2020805@intel.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
 <1490833375-2788-6-git-send-email-sridhar.samudrala@intel.com>
 <CAJ3xEMiU-p5nnQSzWDYDsfam+gEK0TnAEz8uB7V7qWMm-fjH8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2116 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751210AbdDCSwu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Apr 2017 14:52:50 -0400
In-Reply-To: <CAJ3xEMiU-p5nnQSzWDYDsfam+gEK0TnAEz8uB7V7qWMm-fjH8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/2017 2:26 AM, Or Gerlitz wrote:
> On Thu, Mar 30, 2017 at 3:22 AM, Sridhar Samudrala
> <sridhar.samudrala@intel.com> wrote:
>> Any frames sent via port netdevs are sent as directed transmits to the
>> corresponding VFs.
> okay, cool
>
>> In switchdev mode, broadcasts from VFs are received by the PF and passed
>> to corresponding port representor netdev.
> not following.
>
> If a VF sends a packet and it doesn't match any HW steering rule, then
> it has to meet some default rule. Such rule can be fwd to host CPU or drop
> or something else.
>
> E.g in mlx5 currently it's fwd to CPU --> the packet is delivered to
> the HW queue
> of the corresponding VF rep is received into the host networking stack
> from there
> (the VF rep does netif_rx).
fwd to CPU as default rule is not possible with the current generation 
of hw/fw.
So we would like to enable switchdev to expose the port representors and 
start
adding offloads in an incremental way.

>
> In this series you are not doing any offloading, right? so 100% of the packets
> sent by VFs should meet your default rule which I assume you want to be
> fwd to host CPU (--> vf rep)
>
> Is that broadcast a special case which will remain in place also when you
> add fdb/tc offloading? why not let the HW steering configuration for all types
> of traffic be dictated by offloading some SW switching rules?
>
> FWIW - I will not be online till Tues, so will see you reply only then
>
> Or.
