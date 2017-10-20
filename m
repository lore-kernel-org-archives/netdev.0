From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v2 5/6] devlink: Adding num MSI-X vectors per VF
 NVRAM config param
Date: Fri, 20 Oct 2017 10:19:31 -0400
Message-ID: <CA+Jmh7FT789PfH908KK+x1+ehrvbiaaovori1w9yWe7+CFhFTg@mail.gmail.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-6-git-send-email-steven.lin1@broadcom.com>
 <AM0PR0502MB368347E87E48F7EB04AF1513BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
 <20171019213955.GG1978@nanopsycho.orion> <CA+Jmh7HCC-CgU16E8vSm541KnNUKZUgWfT0tPVx73cJxREC0Ag@mail.gmail.com>
 <20171020141010.GB1994@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Yuval Mintz <yuvalm@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:51466 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751765AbdJTOTw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 10:19:52 -0400
Received: by mail-qt0-f193.google.com with SMTP id h4so18604630qtk.8
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 07:19:52 -0700 (PDT)
In-Reply-To: <20171020141010.GB1994@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 10:10 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Oct 20, 2017 at 04:03:55PM CEST, steven.lin1@broadcom.com wrote:
>>On Thu, Oct 19, 2017 at 5:39 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Thu, Oct 19, 2017 at 10:32:21PM CEST, yuvalm@mellanox.com wrote:
>>>>> Adding DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF permanent
>>>>> config
>>>>> parameter.  Defines number of MSI-X vectors allocated per VF.
>>>>> Value is permanent (stored in NVRAM), so becomes the new default
>>>>> value for this device.
>>>>
>>>>Sounds like you're having this enforce the same configuration for all child VFs.
>>>
>>> Yeah, this sounds like per-port config.
>>>
>>
>>Well, it gets a little tricky here.  I assume some cards handle this
>>per-port.  Other cards might handle this per PF, where PF may not
>>always correspond 1:1 with a port.  And some cards maybe just allow a
>>single value for this parameter for the entire card, covering all
>>ports/PFs.
>>
>>To keep things simple and as general as possible, it made sense to set
>>all parameters on a per-PCI device level.  As I mentioned in my
>>cover-letter, the devices most likely to use these proposed commands
>>do not have a single "whole asic" PCI b/d/f with internal mechanism
>>for accessing ports - most expose each port (and each function on each
>>port) as a separate PCI b/d/f, with no separate "whole asic" PCI
>>b/d/f.  That's how the BCM cards work, and I think that's how the MLNX
>>cards work, and others that would be likely to use these cmds.
>>
>>So, to summarize, you direct the command to the PCI b/d/f you want to
>>target.  Does this make sense?
>
> So you plan to have 1 devlink instance for each vf? Not sure that
> does sound right to me :/
>

For the commands proposed in this patchset, AFAIK they all apply on a
per-PF or broader, i.e. per-port or whole-card, granularity, since
they affect permanent config that applies at boot-up.  So, no, the VFs
don't really come into play here.
