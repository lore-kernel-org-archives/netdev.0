From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration
 from device tree
Date: Tue, 4 Feb 2014 11:01:23 -0800
Message-ID: <CAGVrzcbo7Ebvq1G7Gn+BJWsN622a5AiC6QkJKuhkpuX3yzUbHA@mail.gmail.com>
References: <7510122.cayuQ6qt8r@wuerfel> <1389999459-9483-1-git-send-email-matthew.garrett@nebula.com>
 <1390145654.16433.102.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matthew Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1390145654.16433.102.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-01-19 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>:
> On Fri, 2014-01-17 at 17:57 -0500, Matthew Garrett wrote:
>> Some hardware may be broken in interesting and board-specific ways, such
>> that various bits of functionality don't work. This patch provides a
>> mechanism for overriding mii registers during init based on the contents of
>> the device tree data, allowing board-specific fixups without having to
>> pollute generic code.
> [...]
>> --- a/Documentation/devicetree/bindings/net/phy.txt
>> +++ b/Documentation/devicetree/bindings/net/phy.txt
>> @@ -23,6 +23,21 @@ Optional Properties:
>>    assume clause 22. The compatible list may also contain other
>>    elements.
>>
>> +The following properties may be added to either the phy node or the parent
>> +ethernet device. If not present, the hardware defaults will be used.
>> +
>> +- phy-mii-advertise-10half: 1 to advertise half-duplex 10MBit, 0 to disable
>> +- phy-mii-advertise-10full: 1 to advertise full-duplex 10MBit, 0 to disable
>> +- phy-mii-advertise-100half: 1 to advertise half-duplex 100MBit, 0 to disable
>> +- phy-mii-advertise-100full: 1 to advertise full-duplex 100MBit, 0 to disable
>> +- phy-mii-advertise-100base4: 1 to advertise 100base4, 0 to disable
>> +- phy-mii-advertise-1000half: 1 to advertise half-duplex 1000MBit, 0 to disable
>> +- phy-mii-advertise-1000full: 1 to advertise full-duplex 1000MBit, 0 to disable
>
> Are these really all needed?  Apparently there is a standard 'max-speed'
> property on Ethernet devices already, which I think is probably
> sufficient to express the actual restrictions of some boards.

This is what I think as well. Maybe there is the need for something
more fine-grained, although I really doubt it.

>
>> +- phy-mii-manual-master: 1 to enable manual master/slave configuration, 0
>> +  to disable manual master/slave configuration
> [...]
>
> Although the standard calls this 'manual', if it's set in the DT it
> won't really be a manual setting.  The description should probably
> clarify that.
>
> I think the name should include 'master-slave' or 'clock-role' rather
> than just 'master', as currently it suggests only the master role can be
> forced.

Right, and this would match what 802.3-2008, Section 22.2.4.3.7 mentions.

>
> Ben.
>
> --
> Ben Hutchings
> friends: People who know you well, but like you anyway.



-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
