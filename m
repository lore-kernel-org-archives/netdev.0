From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Driver profiles RFC
Date: Sun, 13 Aug 2017 08:32:48 +0200
Message-ID: <20170813063248.GA1850@nanopsycho>
References: <6d8560fa-8346-0c43-272d-d39be65ea82f@mellanox.com>
 <20170811145738.6f92e451@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>, ivecera@redhat.com,
        roopa@cumulusnetworks.com, Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        john.fastabend@gmail.com, Andrew Lunn <andrew@lunn.ch>,
        mlxsw <mlxsw@mellanox.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37296 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751202AbdHMGcv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 02:32:51 -0400
Received: by mail-wm0-f65.google.com with SMTP id t138so10899808wmt.4
        for <netdev@vger.kernel.org>; Sat, 12 Aug 2017 23:32:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170811145738.6f92e451@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 11, 2017 at 11:57:38PM CEST, kubakici@wp.pl wrote:
>On Tue, 8 Aug 2017 16:15:41 +0300, Arkadi Sharshevsky wrote:
>> Driver <--> Devlink API
>> =======================
>> Each driver will register his resources with default values at init in
>> a similar way to DPIPE table registration. In case those resources already
>> exist the default values are discarded. The user will be able to dump and
>> update the resources. In order for the changes to take place the user will
>> need to re-initiate the driver by a specific devlink knob.
>
>What seems missing from the examples is the ability to dump the
>different states - the "pending" configuration and the currently
>applied one.

Agreed, I miss this too.


>
>> The above described procedure will require extra reload of the driver.
>> This can be improved as a future optimization.
>
>I'm a bit lost, this says driver reload is required...

driver will provide "commit" callback. What he does is up to him. In
case of mlxsw, we have to reinstantiate the driver, because FW reset is
required.


>
>> UAPI
>> ====
>> The user will be able to update the resources on a per resource basis:
>> 
>> $devlink dpipe resource set pci/0000:03:00.0 Mem_Linear 2M
>> 
>> For some resources the size is fixed, for example the size of the internal
>> memory cannot be changed. It is provided merely in order to reflect the
>> nested structure of the resource and to imply the user that Mem = Linear +
>> Hash, thus a set operation on it will fail.
>> 
>> The user can dump the current resource configuration:
>> 
>> #devlink dpipe resource dump tree pci/0000:03:00.0 Mem
>> 
>> The user can specify 'tree' in order to show all the nested resources under
>> the specified one. In case no 'resource name' is specified the TOP hierarchy
>> will be dumped.
>> 
>> After successful resource update the drivers hould be re-instantiated in
>> order for the changes to take place:
>> 
>> $devlink reload pci/0000:03:00.0
>
>... but this shows a devlink reload tigger, so no driver reload?  Were
>you describing two possible solutions?  One with persistent kernel
>database of configs (persistent across driver reloads) and one with no
>persistence and the driver is managing reinit internally when triggered
>via devlink?

This is misunderstanding. There is no driver reload (modprobe -r &&
modprobe)


>
>Another thing that comes to mind is - in case HW/FW reinit takes long
>would it make sense to incorporate some form of pre-population of those
>defaults somehow?  If user knows exactly the config they want upon
>boot, it would seem cleaner if the reconfig did not have to happen and
>devices started out in the right mode.

We were discussing it. There are couple of ways to achieve that, none of
that is very nice. So we decided to leave this for later, when/if it is
needed.
