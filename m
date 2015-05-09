From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 18/21] switchdev: convert fib_ipv4_add/del
 over to switchdev_port_obj_add/del
Date: Sat, 9 May 2015 09:10:25 +0200
Message-ID: <20150509071025.GB2129@nanopsycho>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
 <1430847297-15728-19-git-send-email-sfeldma@gmail.com>
 <20150507161010.GE2121@nanopsycho>
 <554CC5E3.5000806@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35489 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649AbbEIHKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 03:10:30 -0400
Received: by widdi4 with SMTP id di4so52425309wid.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 00:10:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <554CC5E3.5000806@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 08, 2015 at 04:19:15PM CEST, john.r.fastabend@intel.com wrote:
>On 05/07/2015 09:10 AM, Jiri Pirko wrote:
>> Tue, May 05, 2015 at 07:34:54PM CEST, sfeldma@gmail.com wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> The IPv4 FIB ops convert nicely to the switchdev objs and we're left with
>>> only four switchdev ops: port get/set and port add/del.  Other objs will
>>> follow, such as FDB.  So go ahead and convert IPv4 FIB over to switchdev
>>> obj for consistency, anticipating more objs to come.
>>>
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> 
>> Acked-by: Jiri Pirko <jiri@resnulli.us>
>
>Hi Scott, Jiri,
>
>Now that your converting IPv4 and FDB over to objs this starts to look like
>table operations to me. You have add/del/dump operations on them but are
>missing the resource piece and how objects are inter-related. I assume in
>the end you will have an "obj" for each one of your hardware tables.

Yes, these are objects, but very well defined ones. FDB entry is well
defined, I don't see a need to abstract it.

>
>At this point I think it might be better to lay this onto the Flow API
>I wrote but tighten up the Flow API logic a bit to constrain it. This
>patch at least doesn't appear to leak into userspace at all which is good
>so there is no problem doing the conversion after this is applied. This
>will help I think when Roopa adds the improved failure schemes. Because
>at least in some of my use cases I want to have some sense when rules
>are going to start failing and how they are interconnected with other
>tables before I start working on the switch.

I need to see that patch you mention. But anyway, we can certainly
change the lower parts when needed.


>
>Thanks,
>.John
>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>
