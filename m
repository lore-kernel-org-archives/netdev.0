From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Implement FDB operations
Date: Fri, 23 Oct 2015 13:20:30 -0700
Message-ID: <562A968E.9020303@gmail.com>
References: <1445625487-16313-1-git-send-email-f.fainelli@gmail.com> <20151023192824.GA21943@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	andrew@lunn.ch, linux@roeck-us.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35521 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbbJWUVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 16:21:06 -0400
Received: by pasz6 with SMTP id z6so126774052pas.2
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 13:21:05 -0700 (PDT)
In-Reply-To: <20151023192824.GA21943@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/10/15 12:28, Vivien Didelot wrote:
> On Oct. Friday 23 (43) 11:38 AM, Florian Fainelli wrote:
>> Add support for the FDB add, delete, and dump operations. The add and
>> delete operations are implemented using directed ARL operations using
>> the specified MAC address and consist in a read operation, write and
>> readback operation.
>>
>> The dump operation consists in using the ARL search and software
>> filtering entries which are not for the desired port.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---

[snip]

>> +	return -ENOENT;
>> +}
> 
> What is the purpose of the "vid" parameter in bcm_sf2_arl_read?

To support an optional VID the day we have proper VLAN support in this
driver.

>> +static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, int port,
>> +			      const struct switchdev_obj_port_fdb *fdb)
>> +{
>> +	struct bcm_sf2_priv *priv = ds_to_priv(ds);
>> +
>> +	return bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
>> +}
> 
> I'm wondering if you are populating the FDB of the invalid VLAN 0 here.
> 
> Does your ARL consider that fdb->vid == 0 means "this port's FDB" and
> not "FDB of VLAN 0"?

(please trim your replies)

I do not think this matters right now, since 802.1q is not currently
enabled/supported in the driver, but maybe I am trivializing this?
-- 
Florian
