From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 1/4] switchdev: add bridge attributes
Date: Thu, 8 Oct 2015 19:22:19 -0700
Message-ID: <CAE4R7bBFE_X0LitnJHnNKaPah7EKU14K7ZV2QmkiMFiZ3DYTVw@mail.gmail.com>
References: <1444284283-33601-1-git-send-email-sfeldma@gmail.com>
 <1444284283-33601-2-git-send-email-sfeldma@gmail.com> <20151008083923.GE2186@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33112 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbbJICWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:22:39 -0400
Received: by obbbh8 with SMTP id bh8so52888096obb.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:22:38 -0700 (PDT)
In-Reply-To: <20151008083923.GE2186@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 1:39 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Oct 08, 2015 at 08:04:40AM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Setting the stage to push bridge-level attributes down to port driver so
>>hardware can be programmed accordingly.  Bridge-level attribute example is
>>ageing_time.  This is a per-bridge attribute, not a per-bridge-port attr.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>> include/net/switchdev.h      |    5 +++++
>> include/uapi/linux/if_link.h |    2 +-
>> 2 files changed, 6 insertions(+), 1 deletion(-)
>>
>>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>index 89266a3..8d92cd0 100644
>>--- a/include/net/switchdev.h
>>+++ b/include/net/switchdev.h
>>@@ -43,6 +43,7 @@ enum switchdev_attr_id {
>>       SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
>>       SWITCHDEV_ATTR_ID_PORT_STP_STATE,
>>       SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
>>+      SWITCHDEV_ATTR_ID_BRIDGE,
>> };
>>
>> struct switchdev_attr {
>>@@ -52,6 +53,10 @@ struct switchdev_attr {
>>               struct netdev_phys_item_id ppid;        /* PORT_PARENT_ID */
>>               u8 stp_state;                           /* PORT_STP_STATE */
>>               unsigned long brport_flags;             /* PORT_BRIDGE_FLAGS */
>>+              struct switchdev_attr_bridge {          /* BRIDGE */
>>+                      enum ifla_br attr;
>
> I don't like pushing down IFLA_BR_* values throught switchdev. I think
> it might better to just intruduce:
> SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME
>
> and "u32 ageing_time" here. Something similar to stp_state. Much easier
> to read and does not give blank cheque for passing any bridge IFLA_BR_*
> down to drivers.
>
> It also aligns with bridge code nicely, I believe.

Done, v3 sent with your suggested change.
