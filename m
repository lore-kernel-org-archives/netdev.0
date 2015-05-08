From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v5 12/21] switchdev: remove old switchdev_port_bridge_setlink
Date: Thu, 7 May 2015 22:07:06 -0700
Message-ID: <CAE4R7bCy8xrqVMpEnR0Y8WeXZ3dTK5f1vXwkftD4m=z+MThkvQ@mail.gmail.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
	<1430847297-15728-13-git-send-email-sfeldma@gmail.com>
	<20150507153637.GB2121@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:32965 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbbEHFHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 01:07:07 -0400
Received: by qcvo8 with SMTP id o8so8445040qcv.0
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 22:07:06 -0700 (PDT)
In-Reply-To: <20150507153637.GB2121@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 7, 2015 at 8:36 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, May 05, 2015 at 07:34:48PM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>New attr-based bridge_setlink can recurse lower devs and recover on err, so
>>remove old wrapper.  Also, restore br_setlink back to original and don't
>>call into SELF port driver.  rtnetlink.c:bridge_setlink already does a call
>>into port driver for SELF.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>> include/net/switchdev.h   |   17 -----------------
>> net/bridge/br_netlink.c   |   11 +----------
>> net/switchdev/switchdev.c |   30 ------------------------------
>> 3 files changed, 1 insertion(+), 57 deletions(-)
>>
>>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>index aa6c370..ce5ceb2 100644
>>--- a/include/net/switchdev.h
>>+++ b/include/net/switchdev.h
>>@@ -122,8 +122,6 @@ int switchdev_port_attr_set(struct net_device *dev,
>>                           struct switchdev_attr *attr);
>> int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj);
>> int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj);
>>-int switchdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
>>-                            u16 flags);
>
> I don't understand why you remove this. Would for example bond compile
> after this?

Looks like a patching error on my part...fixed in v6...
