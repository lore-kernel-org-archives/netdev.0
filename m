From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Fri, 20 Feb 2015 09:29:30 -0800
Message-ID: <54E76EFA.1050209@cumulusnetworks.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, gospo@cumulusnetworks.com,
	vbandaru@broadcom.com, siva.mannem.lnx@gmail.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:45005 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754429AbbBTR3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 12:29:32 -0500
Received: by pdbnh10 with SMTP id nh10so8948705pdb.11
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 09:29:32 -0800 (PST)
In-Reply-To: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/19/15, 11:09 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Add a new NTF_EXT_FLAG to mark an FDB as externally aged, for example by
> offload hardware.   Switchdev driver/devices can set this flag when learning a
> new FDB entry and SW (the bridge driver) will skip this entry when running its
> ageing task.  If flag is set, the driver/device is responsible for calling
> call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL, ...) when entry expires.
>
> This give the flexibility for driver/device to decide ageing policy based on
> its capabilities.  For devices managing many FDB entries, it is desireable for
> the device to aged out its own entries.  Devices not capable of aged entries
> can rely of SW to age out the entries.
>
scott, patches look good. However, I am not sure yet if there is a need 
to make it a per fdb entry flag.

At some point we will also need the hw ageing parameter to be configurable.
So other approach could be,
- ageing parameter on bridge gets offloaded the hw
- so, by default hw and kernel age their own entries using the same 
bridge device default timer
- User can explicitly disable HW ageing by using self (this needs some 
more thought because now the call is on the bridge device)

Thanks,
Roopa
