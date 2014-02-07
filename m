From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration
 from device tree
Date: Fri, 7 Feb 2014 14:43:15 -0800
Message-ID: <CAGVrzcaht=ZVF9uu=VTaGBk4-ayRkYhOEpoWA4b2sprCaVrbKA@mail.gmail.com>
References: <7510122.cayuQ6qt8r@wuerfel> <1389999459-9483-1-git-send-email-matthew.garrett@nebula.com>
 <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F6B8BCA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matthew Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
To: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B8BCA-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-02-05 David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>:
> From: Florian Fainelli
>> It would be good to explain exactly how your hardware is broken
>> exactly. I really do not think that such a fine-grained setting where
>> you could disable, e.g: 100BaseT_Full, but allow 100BaseT_Half to
>> remain usable makes that much sense. In general, Gigabit might be
>> badly broken, but 100 and 10Mbits/sec should work fine. How about the
>> MASTER-SLAVE bit, is overriding it really required?
>
> There are plenty of systems out there where you'd want to disable
> either HDX or FDX modes.
> The MAC unit has to know whether the PHY is in HDX or FDX in order
> to work properly. Many do not need to know the speed - since the
> PHY is responsible for the tx/rx fifo clock.
> Getting the negotiated speed out of the PHY can be difficult, while
> the ANAR can easily be set.
> Unfortunately it is usually impossible to disable the 'fall-back'
> 10M HDX.

The problem that I have with that approach in general is that:

- it bloats the code for a set of properties that are going to be used
by hopefully a few percentage of the actual Device Trees out there
- it puts no limits on what is acceptable/best-practice to be put in
terms of configuration in the Device Tree, how about the 16x16 other
register values out there which are standardized?
- a PHY fixup should be registered based on the top-level compatible
property for a given board where the specific PHY on a specific board
is known to be broken
- make things incredibly harder to debug than they are today

I do acknowledge the need to have a solution to these problems, but
this seems to duplicate existing mechanisms available (e.g: PHY
fixups) without leveraging information that should be properly flagged
in the Device Tree (board model, root-node compatible string etc...)
to allow software to take corrective measures.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
