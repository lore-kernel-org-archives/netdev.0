From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 0/4] Configuring traffic classes via new
 hardware offload mechanism in tc/mqprio
Date: Mon, 22 May 2017 06:25:53 +0300
Message-ID: <CAJ3xEMhtgt4==-GbAWjT8fGMQhoRAzHhFbaVgrfWgJhSaxXr9g@mail.gmail.com>
References: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
 <CAJ3xEMjTDW7sQ5CFmTyR5xMpin_WFFQg-S8imWMBpXWuS1zvVw@mail.gmail.com> <CAKgT0Ue6tDOE8L4thktyje-erGkVMmtO7zyp0FRgmRPYOppjQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36425 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757163AbdEVDZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 23:25:54 -0400
Received: by mail-oi0-f49.google.com with SMTP id h4so146058717oib.3
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 20:25:53 -0700 (PDT)
In-Reply-To: <CAKgT0Ue6tDOE8L4thktyje-erGkVMmtO7zyp0FRgmRPYOppjQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 1:35 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Sat, May 20, 2017 at 2:15 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Sat, May 20, 2017 at 3:58 AM, Amritha Nambiar
>> <amritha.nambiar@intel.com> wrote:
>>> The following series introduces a new harware offload mode in tc/mqprio
>>
>> Wait, we have already a HW QoS model introduced by John F and Co
>> couple of years ago,  right?
>
> I assume you are referring to the ETS portion of DCBX? If so then yes
> we have something there, but there is a fairly high level of
> complexity and dependencies in order to enable that. What we have in
> mind doesn't really fit with DCBX and the problem is the spec calls
> out that you really have to have support for DCBX in order to make use
> of ETS. What we are trying to do here is provide a lightweight way of
> doing this configuration similar to how mqprio was already providing a
> lightweight way of enabling multiple traffic classes.

UAPI wise, we are talking on DCB, not DCBX, right? the X-portion comes
into play if some user-space entity run LLDP traffic and calls into
the kernel to configure (say) ETS. If there are some issues to use the
existing user-space tool (lldpad tool/daemon) to do DCB without X, one
can/should fix them or introduce another/simpler tool that in a
lightweight manner only configures things w.o exchanging.

So to clarify, the essence of this series is introducing a 2nd way to
configure ETS and rate limit?

>> Please elaborate in few sentence if you are extending it/replacing it,
>> why we want to do that and what are the implications on existing
>> applications UAPI wise.

> This is meant to be an extension of the existing structure. It can be
> ignored by the driver and instead only have the basic hw offload
> supported. In such a case the command will still return success but
> any rate limits and queue configuration can be ignored. In the case of
> the current implementation the queue configuration was already being
> ignored so we opted to re-purpose the "hw" flag so that if you pass a
> value greater than 1 and the driver doesn't recognize the value it has
> the option to just ignore the extra bits it doesn't recognize and
> return 1 as it did before for the hw flag in mqprio.

So the user asked to configure something and the kernel returned
success but the config was not plugged to the hw? sounds to me like
possible (probable) source of troubles and complaints.

>> Below you just say in the new mode Qos is configured with knobs XYZ --
>> this is way not enough

> Can you clarify what you are asking for here? Amritha included an
> example in patch 1 of a command line that enabled 2 traffic classes
> with rate limits. Is there something more specific you are looking for?

you were referring to the questions I posted, so we can continue the
discussion from here.
