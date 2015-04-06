From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 19/26] switchdev: add new swdev_port_bridge_getlink
Date: Mon, 6 Apr 2015 14:13:12 -0700
Message-ID: <CAE4R7bAP2bbc=90G_VqDHUMOOhYs7MtnYrXEQ2Oz633HoD34Uw@mail.gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
	<1427962212-18411-20-git-send-email-sfeldma@gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FE348@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36593 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbDFVNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 17:13:13 -0400
Received: by qgeb100 with SMTP id b100so15923972qge.3
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 14:13:12 -0700 (PDT)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067FE348@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 4, 2015 at 9:56 AM, Arad, Ronen <ronen.arad@intel.com> wrote:
>
>
>>-----Original Message-----
>>From: sfeldma@gmail.com [mailto:sfeldma@gmail.com]
>>Sent: Thursday, April 02, 2015 1:10 AM
>>To: netdev@vger.kernel.org
>>Cc: jiri@resnulli.us; roopa@cumulusnetworks.com; linux@roeck-us.net;
>>f.fainelli@gmail.com; Samudrala, Sridhar; Arad, Ronen
>>Subject: [PATCH net-next v3 19/26] switchdev: add new
>>swdev_port_bridge_getlink
>>
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Like bridge_setlink, add swdev wrapper to handle bridge_getlink and call into
>>port driver to get port attrs.  For now, only BR_LEARNING and BR_LEARNING_SYNC
>>are returned.  To add more, we'll probably want to break away from
>>ndo_dflt_bridge_getlink() and build the netlink skb directly in the swdev
>>code.

[cut]

>
> swdev_port_bridge_getlink and the function it wraps
> ndo_dflt_bridge_getlink are only useful when all you need is to return
> a set of brport attributes.
> When a switchdev driver supports VLAN filtering without being enslaved
> to a bridge this no longer works. ndo_dflt_bridge_getlink will end up in
> a netlink RTM_NEWLINK message without the VLAN filtering info which is
> maintained internally by the switchdev driver.
> The driver will have to duplicate the code in ndo_dflt_bridge_getlink in
> order to return a single RTM_NEWLINK message per port.
> Can we break ndo_dflt_bridge_getlink to components that could be used
> by such driver?
> It would be useful to have one function that could fill the
> IFLA_PROTINFO and another one for the IFLA_AF_SPEC.

I couldn't find a consumer of the RTM_NEWLINK msg returned from
RTM_GETLINK that wants the VLAN part of afspec.  Did I miss one?

-scott
