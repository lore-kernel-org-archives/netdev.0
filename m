From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next RFC 5/5] rocker: explicitly set SW ageing for rocker
Date: Fri, 20 Feb 2015 06:56:53 -0800
Message-ID: <CAE4R7bAgjO6z4Fp56Yass==FPBR3viCMUXdk1E9FxG3dOaHXzg@mail.gmail.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
	<1424416195-19098-6-git-send-email-sfeldma@gmail.com>
	<20150220092518.GA2008@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>, andrew@lunn.ch,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	vbandaru@broadcom.com, Siva Mannem <siva.mannem.lnx@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:49111 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754193AbbBTO4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 09:56:54 -0500
Received: by mail-qg0-f50.google.com with SMTP id e89so14287521qgf.9
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 06:56:54 -0800 (PST)
In-Reply-To: <20150220092518.GA2008@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 1:46 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Feb 20, 2015 at 08:09:55AM CET, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Rocker (for now) will rely on SW (bridge) ageing.  Other drivers/devices may
>>wish to set NTF_EXT_AGED to turn off SW (bridge) ageing.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>> drivers/net/ethernet/rocker/rocker.c |    9 +++++----
>> 1 file changed, 5 insertions(+), 4 deletions(-)
>>
>>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>>index 34389b6a..7b55934 100644
>>--- a/drivers/net/ethernet/rocker/rocker.c
>>+++ b/drivers/net/ethernet/rocker/rocker.c
>>@@ -3026,10 +3026,11 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
>>               container_of(work, struct rocker_fdb_learn_work, work);
>>       bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
>>       bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
>>-      struct netdev_switch_notifier_fdb_info info;
>>-
>>-      info.addr = lw->addr;
>>-      info.vid = lw->vid;
>>+      struct netdev_switch_notifier_fdb_info info = {
>>+              .addr = lw->addr,
>>+              .vid = lw->vid,
>>+              .ntf_flags = NTF_EXT_LEARNED,
>>+      };
>
> I think that this patch should be before "bridge: call external learn add
> if adding FDB entry with NTF_EXT_LEARNED set" in order to not break
> functionality during bisect.

Ok, I reordered 'em. Thanks.
