From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 07/24] switchdev: add port vlan obj
Date: Mon, 13 Apr 2015 15:27:03 +0200
Message-ID: <20150413132703.GD2090@nanopsycho.lan>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
 <1428905838-14920-8-git-send-email-sfeldma@gmail.com>
 <20150413131625.GC2090@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35065 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbbDMN1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 09:27:07 -0400
Received: by wgyo15 with SMTP id o15so80816444wgy.2
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 06:27:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150413131625.GC2090@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 13, 2015 at 03:16:25PM CEST, jiri@resnulli.us wrote:
>Mon, Apr 13, 2015 at 08:17:01AM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>VLAN obj has flags (PVID and untagged) as well as start and end vid ranges.
>>The swdev driver can optimize programing the device using the ranges.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>> include/net/switchdev.h |    8 ++++++++
>> 1 file changed, 8 insertions(+)
>>
>>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>index f5f7733..d3cc8eb 100644
>>--- a/include/net/switchdev.h
>>+++ b/include/net/switchdev.h
>>@@ -45,12 +45,20 @@ struct fib_info;
>> 
>> enum swdev_obj_id {
>> 	SWDEV_OBJ_UNDEFINED,
>>+	SWDEV_OBJ_PORT_VLAN,
>> };
>> 
>> struct swdev_obj {
>> 	enum swdev_obj_id id;
>> 	enum swdev_trans trans;
>> 	u32 flags;
>>+	union {
>>+		struct swdev_obj_vlan {			/* PORT_VLAN */
>>+			u16 flags;
>>+			u16 vid_start;
>>+			u16 vid_end;
>>+		} vlan;
>>+	};
>
>Same here. Please squash this with the next patch.

I mean 09. The infrastructure should be first, usage (by driver) after
that.

>
>
>> };
>> 
>> /**
>>-- 
>>1.7.10.4
>>
