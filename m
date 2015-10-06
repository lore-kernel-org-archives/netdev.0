From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: HW communication debugging interface - ideas?
Date: Tue, 6 Oct 2015 17:02:26 +0200
Message-ID: <20151006150226.GI2165@nanopsycho.orion>
References: <20151005095633.GE2278@nanopsycho.orion>
 <20151005144941.GC8673@lunn.ch>
 <20151005145542.GJ2278@nanopsycho.orion>
 <20151005145842.GD8673@lunn.ch>
 <20151005151821.GK2278@nanopsycho.orion>
 <56129745.1020805@gmail.com>
 <20151005153554.GM2278@nanopsycho.orion>
 <56129B7D.4040402@gmail.com>
 <20151006081457.GD2165@nanopsycho.orion>
 <5613E091.6000001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, "Rosen, Rami" <rami.rosen@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34738 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbbJFPC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 11:02:29 -0400
Received: by wicfx3 with SMTP id fx3so170986884wic.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 08:02:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5613E091.6000001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 06, 2015 at 04:54:09PM CEST, john.fastabend@gmail.com wrote:
>On 15-10-06 01:14 AM, Jiri Pirko wrote:
>> Mon, Oct 05, 2015 at 05:47:09PM CEST, john.fastabend@gmail.com wrote:
>>> On 15-10-05 08:35 AM, Jiri Pirko wrote:
>>>> Mon, Oct 05, 2015 at 05:29:09PM CEST, john.fastabend@gmail.com wrote:
>>>>> On 15-10-05 08:18 AM, Jiri Pirko wrote:
>>>>>> Mon, Oct 05, 2015 at 04:58:42PM CEST, andrew@lunn.ch wrote:
>>>>>>> On Mon, Oct 05, 2015 at 04:55:42PM +0200, Jiri Pirko wrote:
>>>>>>>> Mon, Oct 05, 2015 at 04:49:41PM CEST, andrew@lunn.ch wrote:
>>>>>>>>>>> Are you referring here to messages of the EMAD protocol ?
>>>>>>>>>
>>>>>>>>> I know nothing about this protocol.....
>>>>>>>>>
>>>>>>>>> Does it at least use standard Ethernet framing? Source and Destination
>>>>>>>>> header and an EtherType which mean EMAD?
>>>>>>>>
>>>>>>>> Yep, but that does not really matter. I believe we should find debugging
>>>>>>>> interface which is protocol agnostic. Just arbitrary messages
>>>>>>>> monitoring.
>>>>>>>
>>>>>>> Hi Jiri
>>>>>>>
>>>>>>> O.K, it is just that you mentioned wireshark. Passing the frames to
>>>>>>> network interface taps would make this trivial.
>>>>>>
>>>>>> That is true. But using netlink+nlmon would do the same.
>>>>>
>>>>> Also I guess if you go this direction you want to make it generic
>>>>> enough for any drivers to use it to snoop software/firmware msgs. This
>>>>> is common across many devices.
>>>>
>>>> Yes, definitelly, this should be something generic to be usable for
>>>> every device type.
>>>>
>>>>
>>>>>
>>>>> In the past though I've just used ethtool dump commands and some
>>>>> "scripts" on top of this to debug devices. And when it got really
>>>>> bad wrote some throw away code to debug my issue. I guess it might
>>>>> be nice to have something in the kernel to improve this but have
>>>>> you considered using the tracing features that already exist?
>>>>
>>>> Which ones do you have in mind?
>>>>
>>>
>>> I was thinking something like kprobes+bpf to dump a trace and
>>> then a lua script in wireshark to parse the input and pretty
>>> print it for users. This might get you good-enough support without
>>> having to carry it around in the kernel just so we can debug
>>> the devices. We could build some libs/pkgs around it in userspace
>>> and get it published somewhere so we can all work on it together.
>> 
>> Well, I was thinking rather about some standard interface, not dependent
>> on actual kernel internals.
>> 
>
>
>Sure just throwing out an idea. I suspect whatever interface you have
>will include the vendor-id or some other identifier and a set of
>parsers in user space to pretty print the msg.

Yes, that is the plan.
