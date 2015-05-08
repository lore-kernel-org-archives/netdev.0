From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next v5 18/21] switchdev: convert fib_ipv4_add/del
 over to switchdev_port_obj_add/del
Date: Fri, 08 May 2015 07:19:15 -0700
Message-ID: <554CC5E3.5000806@intel.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com> <1430847297-15728-19-git-send-email-sfeldma@gmail.com> <20150507161010.GE2121@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch,
	simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:50973 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652AbbEHOT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2015 10:19:29 -0400
In-Reply-To: <20150507161010.GE2121@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2015 09:10 AM, Jiri Pirko wrote:
> Tue, May 05, 2015 at 07:34:54PM CEST, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> The IPv4 FIB ops convert nicely to the switchdev objs and we're left with
>> only four switchdev ops: port get/set and port add/del.  Other objs will
>> follow, such as FDB.  So go ahead and convert IPv4 FIB over to switchdev
>> obj for consistency, anticipating more objs to come.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> 
> Acked-by: Jiri Pirko <jiri@resnulli.us>

Hi Scott, Jiri,

Now that your converting IPv4 and FDB over to objs this starts to look like
table operations to me. You have add/del/dump operations on them but are
missing the resource piece and how objects are inter-related. I assume in
the end you will have an "obj" for each one of your hardware tables.

At this point I think it might be better to lay this onto the Flow API
I wrote but tighten up the Flow API logic a bit to constrain it. This
patch at least doesn't appear to leak into userspace at all which is good
so there is no problem doing the conversion after this is applied. This
will help I think when Roopa adds the improved failure schemes. Because
at least in some of my use cases I want to have some sense when rules
are going to start failing and how they are interconnected with other
tables before I start working on the switch.

Thanks,
.John

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
