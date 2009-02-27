From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 07:36:07 -0700
Message-ID: <49A7FA57.7030504@mlbassoc.com>
References: <49A6B991.2090703@mlbassoc.com> <20090226155726.GO17040@xi.wantstofly.org> <49A73E00.7050406@mlbassoc.com> <20090227011903.GS17040@xi.wantstofly.org> <49A7DBA2.8060605@mlbassoc.com> <49A7DFC0.9050601@mlbassoc.com> <20090227125305.GW17040@xi.wantstofly.org> <49A7E87D.5090203@mlbassoc.com> <20090227132319.GY17040@xi.wantstofly.org> <49A7EA3D.8070800@mlbassoc.com> <20090227142754.GB17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:1665 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754492AbZB0OgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 09:36:21 -0500
In-Reply-To: <20090227142754.GB17040@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Fri, Feb 27, 2009 at 06:27:25AM -0700, Gary Thomas wrote:
> 
>>>>> Also, can you show me what you're filling the dsa platform data
>>>>> structure with?
>>>> struct dsa_platform_data _switch_data = {
>>>>     .port_names[0]  = "lan1.1",
>>>>     .port_names[1]  = "lan1.2",
>>>>     .port_names[2]  = "lan1.3",
>>>>     .port_names[3]  = "lan1.4",
>>>>     .port_names[4]  = "lan1.5",
>>>>     .port_names[5]  = "lan1.6",
>>>>     .port_names[6]  = "lan1.7",
>>>>     .port_names[7]  = "lan1.8",
>>>>     .port_names[10]  = "cpu",
>>>>     .sw_addr = 1,
>>>> };
>>> Just this should do the trick.  So what's not working -- are the
>>> interfaces not showing up?  Or packet RX/TX isn't working?  Or
>>> something else?
>> It won't let me bring up eth0 (my scripts try to run DHCP):
>>   starting network interfaces...
>>   24520:01 not found
>>   eth0: Could not attach to PHY
>>   ip: SIOCSIFFLAGS: No such device
>>
>> As for the other devices, they do show up if I let eth0 try to
>> attach to the PHY:
> 
> OK.  If you try to cheat the gianfar driver by having it attach to
> the PHY for lan1.1, and plug a network cable into lan1.1 so that the
> link goes up and gianfar thinks that the link on eth0 is up, does that
> enable you to pass packets over any of the switch interfaces?  That
> should be working now in this stage.

So, what name do I use when the gianfar is trying to attach?
It makes this call:
  phydev = phy_connect(dev, phy_id, &adjust_link, 0, interface);
where phy_id="24520:01".

Using "24520:01:00" gets an error:
  eth0: 24520:01:00 already attached

Maybe the DSA layer/driver needs to export a device "24520:01"
which pretends all of the things that the gianfar wants (1000Mb/Full/Link)?


-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
