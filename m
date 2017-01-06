From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH 5/6] i40e: Add TX and RX support in switchdev mode.
Date: Fri, 6 Jan 2017 11:24:45 +0200
Message-ID: <CAJ3xEMh7hjPQX1xm9+CRKYjCRp0XzqjA9+YML9+aC2iZ5FhL2A@mail.gmail.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
 <1483078863-22026-6-git-send-email-sridhar.samudrala@intel.com>
 <CAJ3xEMgDAUSE2gVD3dU4UuXFb7k_W-9QgHpg-0c7b5kxRC2=FQ@mail.gmail.com>
 <586693A6.5090105@intel.com> <CAJ3xEMjGuKKge+_hqZPOg2fp3f50TdxGtbKFXwnCZ70rPxmuyw@mail.gmail.com>
 <586D7B4E.2010308@intel.com> <CAJ3xEMgAaXNbvaP0=GcuTsVOOGwPHuSMQf-SeLKpxB8WrbEvng@mail.gmail.com>
 <586EC996.9080205@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        jakub.kicinski@netronome.com, intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34191 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936792AbdAFJYq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 04:24:46 -0500
Received: by mail-oi0-f68.google.com with SMTP id 3so53743972oih.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 01:24:46 -0800 (PST)
In-Reply-To: <586EC996.9080205@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2017 at 12:32 AM, Samudrala, Sridhar
<sridhar.samudrala@intel.com> wrote:
> On 1/5/2017 3:50 AM, Or Gerlitz wrote:

> It looks like you are returning the VF port number as phys_port_name() for a
> VF rep in en_rep.c. Is this correct?

yeah, correct, what we all call the VF rep actually represents the
eswitch vport the VF is connected to. The most flexible input for user
space would be just to get this port number along with the switchdev
ID which tells them to which switch this port belongs.

> By default i am creating VFPR netdev with name as <pf_name>_VF<vf_num>
> For ex; if enp5s0f0 is the pf name, VFPR netdev for VF0 will be enp5s0f0_vf0
>
> If we want udev to follow this syntax should i return '_vf0'  as
> get_phys_port_name() for VF rep 0?

just return a number. Typically the PF is vport #0, so for vf0 you
would return 1, this is aligned with the kernel switchdev
documentation [1]

Or.

[1] http://lxr.free-electrons.com/source/Documentation/networking/switchdev.txt#L104
