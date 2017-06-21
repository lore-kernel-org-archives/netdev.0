From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [oss-drivers] Re: [PATCH net-next 00/12] nfp: add flower app with representors
Date: Wed, 21 Jun 2017 12:00:50 +0300
Message-ID: <CAJ3xEMjTLs0aDLY_zDerm8o0yPmJktzBDE2rJ=QwXQZeS1+qCg@mail.gmail.com>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com> <20170620122417.0c60582e@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35913 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751093AbdFUJAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 05:00:51 -0400
Received: by mail-oi0-f53.google.com with SMTP id p187so28532960oif.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 02:00:51 -0700 (PDT)
In-Reply-To: <20170620122417.0c60582e@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 20, 2017 at 10:24 PM, Jakub Kicinski
<jakub.kicinski@netronome.com> wrote:
> On Tue, 20 Jun 2017 19:13:43 +0300, Or Gerlitz wrote:

>>> Control queues are used to send and receive control messages which are
>>> used to communicate configuration information with the firmware. These
>>> are in separate vNIC to the queues belonging to the PF netdev. The control
>>> queues are not exposed to use-space via a netdev or any other means.

>> Do you have documentation for the control channel or I should look on
>> earlier commits?

> We don't have any docs, the ctrl channel was merged in e5c5180a2302
> ("Merge branch 'nfp-ctrl-vNIC'").  The "control channel" is essentially
> a normal data queue which is specially marked as carrying control
> messages.

>> The control messages you describe here are also the ones that are used
>> to load/unload specific app?

> No, the app loading, PHY port management and other low-level tasks are
> handled by management FW.  The control messages are an application FW
> construct.  The control messages are transported by the datapath and
> since the datapath is entirely under control of apps the management FW
> can't depend on it.  The apps today also completely reload the PCIe
> datapath implementation (which is software defined), so we need to use
> raw memory mappings to communicate with management FW.

> The control messages are mostly used for populating tables and reading
> statistics, because those two need to be fast and low overhead.

Thanks Jakub for that clarification -- I still not sure to see the
high level picture -
will appreciate if you can make a simple  text based sketch here of the
source/dest/sequence of calls/messages (say) from the time the driver is loaded
to when sriov is set with VFs and VF reps

The VF reps where introduced hand in hand with the devlink way to create/destroy
them -- e.g the devlink eswitch commands (mode change, show, enable encap, etc).

Taking your comment that the channels are mostly used for table
population and such,
is there any real reason for you not to use devlink for applying the
configuration? you can
communicate with the FW from your devlink callbacks, isn't that?

Simon, another comment on this series/app, is that the VF reps can
apply for more
use cases beyond flower offload -- e.g FDB or FIB offloads and also
the other way
around, flower offloads can apply to more use cases beyond SRIOV, as any easy
example, you can offload native NIC RX TC rule (drop, header re-write, etc).

Indeed your current app code doesn't have any relation to flower beyond the
name... maybe you can just make a rename and this way it will be less
confusing for you.. when coming to apply more use-cases?

As for flower offloads being applicable beyond SRIOV, lets see if/how
you re-name/phrase the VF reps.

Or.
