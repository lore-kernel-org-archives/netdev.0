From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC] switchdev: clarify ndo_get_phys_port_name() formats
Date: Wed, 26 Jul 2017 12:23:17 +0300
Message-ID: <CAJ3xEMg6jn-x5+bwh--P2nz26T91R0Af64hnc30p-k+_BjcuPQ@mail.gmail.com>
References: <20170724214521.75bf5857@cakuba.netronome.com> <20170725051344.2040-1-jakub.kicinski@netronome.com>
 <20170726054840.GA1845@nanopsycho> <20170726011310.5db489ed@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36609 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbdGZJXS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 05:23:18 -0400
Received: by mail-oi0-f68.google.com with SMTP id m65so10548364oik.3
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 02:23:18 -0700 (PDT)
In-Reply-To: <20170726011310.5db489ed@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 11:13 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Wed, 26 Jul 2017 07:48:40 +0200, Jiri Pirko wrote:

>> I think it would make sense if the driver would just fill-up a struct in
>> the ndo call and core would generate the string.

> I do like the idea of core generating the string.  I have a temptation
> to try to involve devlink in this somehow, since port id and split info
> is already available there.  Perhaps that would only overcomplicate
> things.

> The other question is: can we remove the option to generate an arbitrary
> string completely?  I think Or and mlx5 folks may object since it would
> mean mlx5 VF repr names would change.

What we have today is the representor driver instance setting the VF index as
the of phys port name and we're telling users to have this sort of udev rule:

SUBSYSTEM=="net", ACTION=="add",
ATTR{phys_switch_id}=="<phys_switch_id>", \ ATTR{phys_port_name}!="",
NAME="$PF_NIC$attr{phys_port_name}"

that has affiliation to  the PF where this VF belongs. AFAIK this
model/assumption is now under push to
higher level (open stack), so lets see if/what we want to change here
w.r.t to sriov offloading drivers.

I would opt for an approach where the value returned by the kernel is
the minimal possible and
user-space has flexibility to further orchestrate that with udev
rules. I wasn't fully clear on Jakub's suggestion
which parts must come from the kernel. Do we have any length
limitation for the phys port name?

Or.
