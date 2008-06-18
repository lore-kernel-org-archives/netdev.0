From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Wed, 18 Jun 2008 18:02:28 +0530
Message-ID: <71d336490806180532g4ea7067akc157581cb1fa946d@mail.gmail.com>
References: <20080610205633.11186.45499.stgit@dale>
	 <20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net>
	 <c8028d330806120813q6363c3cemb4aa03ceff6547d1@mail.gmail.com>
	 <48513E4E.4040601@trash.net>
	 <f8ca0a150806141103r56f0530br6b5e78943ac1c92d@mail.gmail.com>
	 <20080614190358.GU22807@obsidianresearch.com>
	 <48562A41.7000304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jason Gunthorpe" <jgunthorpe@obsidianresearch.com>,
	"Amar Mudrankit" <amar.mudrankit@qlogic.com>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	rdreier@cisco.com, poornima.kamath@qlogic.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:43179 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959AbYFRMc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 08:32:29 -0400
Received: by yx-out-2324.google.com with SMTP id 31so303yxl.1
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 05:32:28 -0700 (PDT)
In-Reply-To: <48562A41.7000304@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 2:24 PM, Patrick McHardy <kaber@trash.net> wrote:
> Jason Gunthorpe wrote:
>>
>> On Sat, Jun 14, 2008 at 11:03:08AM -0700, Roland Dreier wrote:
>>>>
>>>> We have linkstate/operstate for this. How is a user supposed
>>>> to configure the network device when it appears at a more or
>>>> less random time from his perspective?
>>
>>
>>>
>>> Well, keep in mind that this driver is for an ethernet virtual NIC
>>> that is actually
>>> remote across another network (an InfiniBand fabric) -- so these devices
>>> can actually appear or disappear at random times by their nature.  It's a
>>> similar issue to, say, a USB ethernet adapter presents -- there's no sane
>>> way
>>> to have operstate set for a device that hasn't been attached yet.
>>
>> I think that is only a fair analogy if the VNIC used some kind of
>> hot-plug auto discovery procedure like USB does. As soon as you
>> require the administrator to run a command to bind a device to a VNIC
>> GID you are much more like a tunnel device and the ethernet device
>> should exist from the moment the administator creates it up until the
>> administator destroys it. The state of the connection to the VNIC
>> should be reflected in some way other than device presence.
>
> Fully agreed.

Is your suggestion that the netdevice needs to be registered as soon
as we get parameters from userspace even if that netdevice stays
inactive until we finish all of our communication with the QLogic EVIC
gateway device over the IB network ?

Currently we register netdevice only after we have made sure that we
can connect to the EVIC and that there are enough resources on the
EVIC to support this virtual ethernet interface. But if we register
the netdevice
without making sure that we can reach the EVIC and that it has resources,
there is a possibility that we register a netdevice that can never
become active.

Isn't our current behavior analogous to an ethernet driver not
registering a netdev if it
can't properly initialize its hardware ?

Regards,
Ram
