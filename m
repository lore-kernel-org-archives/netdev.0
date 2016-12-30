From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH 5/6] i40e: Add TX and RX support in switchdev mode.
Date: Fri, 30 Dec 2016 17:31:55 +0200
Message-ID: <CAJ3xEMgDAUSE2gVD3dU4UuXFb7k_W-9QgHpg-0c7b5kxRC2=FQ@mail.gmail.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com> <1483078863-22026-6-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        jakub.kicinski@netronome.com, intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35698 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754024AbcL3Pb5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 10:31:57 -0500
Received: by mail-oi0-f68.google.com with SMTP id v84so58095268oie.2
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2016 07:31:56 -0800 (PST)
In-Reply-To: <1483078863-22026-6-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 30, 2016 at 8:21 AM, Sridhar Samudrala
<sridhar.samudrala@intel.com> wrote:
> In switchdev mode, broadcast filter is not enabled on VFs, The broadcasts and

nit ", The broadcast" --> ", the broadcasts" or ". The broadcasts"

> unknown frames from VFs are received by the PF and passed to corresponding VF
> port representator netdev.
> A host based switching entity like a linux bridge or OVS redirects these frames
> to the right VFs via VFPR netdevs. Any frames sent via VFPR netdevs are sent as
> directed transmits to the corresponding VFs. To enable directed transmit, skb
> metadata dst is used to pass the VF id and the frame is requeued to call the PFs
> transmit routine.

So the representator netdevs do or don't have TX/RX rings of their
own? if the latter, was there any special locking you had to do for
that?

Are you exposing switchdev ops for the representators? didn't see that
or maybe it's in the 4th patch which didn't make it to the list?
