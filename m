From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [next-queue v6 PATCH 2/7] i40e: Introduce Port Representor
 netdevs and switchdev mode.
Date: Tue, 4 Apr 2017 14:58:01 +0300
Message-ID: <CAJ3xEMikpx3JX5frn0Hbne6tTR9Vgu6Pv22TkEuaJP0mM1Au=w@mail.gmail.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
 <1490833375-2788-3-git-send-email-sridhar.samudrala@intel.com>
 <CAJ3xEMgVeri17KceKhnFUCCFj00yWXKtjwP4r36Pb-CSZiOTng@mail.gmail.com> <58E2974B.30503@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@resnulli.us>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35431 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752998AbdDDL6D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 07:58:03 -0400
Received: by mail-oi0-f41.google.com with SMTP id f193so159621078oib.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 04:58:02 -0700 (PDT)
In-Reply-To: <58E2974B.30503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 3, 2017 at 9:41 PM, Samudrala, Sridhar
<sridhar.samudrala@intel.com> wrote:
> On 3/30/2017 12:17 AM, Or Gerlitz wrote:
>> On Thu, Mar 30, 2017, Sridhar Samudrala wrote:

>>> Port Representator netdevs are created for each PF and VF if the switch
>>> mode is set to 'switchdev'. These netdevs can be used to control and
>>> configure VFs and PFs when they are moved to a different namespace.
>>> They enable exposing statistics, configure and monitor link state, mtu,
>>> filters,fdb/vlan entries etc.

>>> In switchdev mode, broadcasts from VFs are received by the PF and passed
>>> to corresponding port representor netdev.

>> What netdev represents the uplink (wire port) in your impl?

combining your replies from the two emails:

> We don't have a port netdev representing the uplink in this implementation as we
> cannot control the frames going out the uplink via sw rules with the current
> generation of hw/fw.

> fwd to CPU as default rule is not possible with the current generation of hw/fw.
> So we would like to enable switchdev to expose the port representors and start
> adding offloads in an incremental way.

I lost you even deeper

I was asking on frames getting in from the uplink and not getting out
the uplink.

This is about offloading to HW a switching model where the steering
(matching and actions)
comes into play on the port ingress. E.g

VF NIC xmit ---> VF vport e-switch rep recv --> SW or HW steering

other node xmit --> UPLINK vport e-switch rep recv --> SW or HW steering

If your current HW can't let you have "send to CPU" as the default
action on ingress
for the VFs and uplink ports, I am not clear what use-cases you can do
in slow path
(only reps, no offloaded SW rules) and for past path (reps + offloaded
SW rules)...

Can you please elaborate on such use-cases, so the bigger picture is more clear?

Or.
