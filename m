From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 12:59:04 +0100
Message-ID: <4B5ED908.4030608@trash.net>
References: <87k4v5nuej.fsf@purkki.valot.fi> <4B5ED254.7010104@trash.net> <877hr5nkx0.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877hr5nkx0.fsf-ySPBbPOLdCfMApvqMRVM/A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kalle Valo wrote:
> Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org> writes:
> 
>>> Solution 2: SO_PRIORITY with values 256-263
>> You can actually encode any class handle in SO_PRIORITY, all classful
>> qdiscs support classification based on this.
> 
> But what values should I use in an application? There seems to n+1
> different ways to do it, but they all would be specific to my own
> setup.

In case of classful qdisc classification, the values need to
match the class handles.

> I'm after a universal solution, so that there is no need to modify
> applications every time. I would assume that we have a set of rules
> for this. If not, we definitely need one.

Classful qdisc configuration is done by the administrator, so
there is no universal solution.

> Let's take a bittorrent client as an example. The traffic it generates
> is not important and it doesn't matter if bittorrent packets have
> lower priority compared to other streams. What SO_PRIORITY value
> should all bittorrent clients to use to mark their packets as low
> priority (for example background class from IEEE 802.1d Annex G).
> 
> Another example is a VoIP application. The packets need to have as low
> delay as possible, so they need to be prioritised very high (for
> example voice class from 802.1d). What value should such application
> use?

If the device is using the default pfifo_fast qdisc, you
can use values 6 and 7 to map to band 0 (highest priority),
0 and 8-15 to map to band 1 and 1-3 and 5 to map to band 2.

For manually set up qdisc hierarchies you need to ask the
user to specify a priority (or class handle) value.

> Or should applications use something else than SO_PRIORITY?
> 
> Any help is greatly welcomed here :)
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
