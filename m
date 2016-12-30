From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next PATCH 5/6] i40e: Add TX and RX support in switchdev
 mode.
Date: Fri, 30 Dec 2016 09:04:38 -0800
Message-ID: <586693A6.5090105@intel.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com> <1483078863-22026-6-git-send-email-sridhar.samudrala@intel.com> <CAJ3xEMgDAUSE2gVD3dU4UuXFb7k_W-9QgHpg-0c7b5kxRC2=FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        jakub.kicinski@netronome.com, intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31010 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752395AbcL3REo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Dec 2016 12:04:44 -0500
In-Reply-To: <CAJ3xEMgDAUSE2gVD3dU4UuXFb7k_W-9QgHpg-0c7b5kxRC2=FQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2016 7:31 AM, Or Gerlitz wrote:
> On Fri, Dec 30, 2016 at 8:21 AM, Sridhar Samudrala
> <sridhar.samudrala@intel.com> wrote:
>> In switchdev mode, broadcast filter is not enabled on VFs, The broadcasts and
> nit ", The broadcast" --> ", the broadcasts" or ". The broadcasts"
>
>> unknown frames from VFs are received by the PF and passed to corresponding VF
>> port representator netdev.
>> A host based switching entity like a linux bridge or OVS redirects these frames
>> to the right VFs via VFPR netdevs. Any frames sent via VFPR netdevs are sent as
>> directed transmits to the corresponding VFs. To enable directed transmit, skb
>> metadata dst is used to pass the VF id and the frame is requeued to call the PFs
>> transmit routine.
> So the representator netdevs do or don't have TX/RX rings of their
> own? if the latter, was there any special locking you had to do for
> that?
Atleast in the inital implementation,  we are not creating any TX/RX 
rings for VFPR netdevs.
skb->dev is set to the PF device  and skb is requeued via dev_queue_xmit().


>
> Are you exposing switchdev ops for the representators? didn't see that
> or maybe it's in the 4th patch which didn't make it to the list?
Not at this time. In the future patches when we offload fdb/vlan 
functionality, we could use
switchdev ops.
