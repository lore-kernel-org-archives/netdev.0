From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 3/7] rocker: adding port ageing_time for ageing
 out FDB entries
Date: Sat, 19 Sep 2015 10:16:03 -0700
Message-ID: <CAE4R7bDvV5uZPTvKZRj7BWoOr_JayfpaBY9HcM7V2-K6_8vt+w@mail.gmail.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-4-git-send-email-sfeldma@gmail.com> <20150919063058.GA2067@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34754 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814AbbISRQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 13:16:23 -0400
Received: by oiev17 with SMTP id v17so40881615oie.1
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 10:16:23 -0700 (PDT)
In-Reply-To: <20150919063058.GA2067@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 11:30 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Sep 18, 2015 at 09:55:47PM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Follow-up patcheset will allow user to change ageing_time, but for now
>>just hard-code it to a fixed value (the same value used as the default
>>for the bridge driver).
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>> drivers/net/ethernet/rocker/rocker.c |    2 ++
>> 1 file changed, 2 insertions(+)
>>
>>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>>index f55ed2c..eba22f5 100644
>>--- a/drivers/net/ethernet/rocker/rocker.c
>>+++ b/drivers/net/ethernet/rocker/rocker.c
>>@@ -221,6 +221,7 @@ struct rocker_port {
>>       __be16 internal_vlan_id;
>>       int stp_state;
>>       u32 brport_flags;
>>+      unsigned long ageing_time;
>>       bool ctrls[ROCKER_CTRL_MAX];
>>       unsigned long vlan_bitmap[ROCKER_VLAN_BITMAP_LEN];
>>       struct napi_struct napi_tx;
>>@@ -4975,6 +4976,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
>>       rocker_port->port_number = port_number;
>>       rocker_port->pport = port_number + 1;
>>       rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
>>+      rocker_port->ageing_time = 300 * HZ;
>
> How about to add also "BR_DEFAULT_AGEING_TIME" and use it here?

Yes, added for v2
