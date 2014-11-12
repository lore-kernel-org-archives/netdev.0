From: Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Wed, 12 Nov 2014 14:21:59 +0100
Message-ID: <CA+icZUW2iRkoAK10ayJ9PFuFGWBQzKdFe+8mfd=8oKkAp1txtg@mail.gmail.com>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
	<1415120132.31049.11.camel@dcbw.local>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415120132.31049.11.camel-ZWpNTBV2bRGs1BDpvl8NfQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 4, 2014 at 5:55 PM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, 2014-11-04 at 16:11 +0100, Sedat Dilek wrote:
>> Hi,
>>
>> I wanted to understand what is going on the kernel-side when
>> connecting to the Internet via a Huawei E173 USB web-stick (3rd
>> Generation: UMTS / HSPA).
>>
>> Especially the correlation between the diverse USB/NET kernel-drivers
>> and how the networking is setup.
>

[ Sitting in front of a foreign Windows machine ]

[ CC Aleksander ]

Hi Dan,

sorry for the late (and short) response.

AFAICS you have given a "skeleton" for a "usb-wwan-networking"
documentation :-).

Personally, I would like to take into account some kernel-config
options and some more things.

> General overview:  there are many different types of WWAN devices and
> they fall into a couple groups:
>
> 1) PPP-only via serial ports; IP packets are transmitted via a PPP
> interface (eg, ppp0) created after sending some AT commands to the modem
> over that serial port.  IP addressing happens via PPP's IPCP/IPV6CP
> protocols.
>
> 2) Net interface with AT commands over serial ports: the modem provides
> a 'net' interface that is activated with proprietary AT commands over a
> serial port. IP addressing happens via either DHCP on that net interface
> after the AT setup, or the IP/DNS details are queried via proprietary AT
> commands.
>
> 3) Net interface with proprietary protocols: the modem provides a 'net'
> interface that is activated via proprietary protocols (QMI, MBIM, CnS,
> etc).  IP addressing happens either via DHCP on the net interface after
> proprietary protocol setup, or the IP/DNS details are queried via
> proprietary protocol commands.
>
> It's often possible to know what category a device fits into, but even
> devices from the same manufacturer with *the same model number* can fall
> into different categories, because the firmware is different, or because
> the firmware can switch between these categories using special commands.
>

As I have a ppp0 network-interface setup, I guess I have the example #1 here.

What about putting these examples into a section "General Overview:
WWAN devices".

>> I have tested a Ubuntu trusty kernel on my Ubuntu/precise system and
>> compared the configs to get the stuff run on 3.18-rc2+.
>> Beyond the "option" driver, I required usb_serial / usb_wwan to be
>> activated and some more ("cde-ether" or sth. sound similiar...).
>> ( Currently, I am not sitting (it's a Windows machine) in front of my
>> machine, so I cannot send you my latest kernel-config. )
>>
>> As usually I looked into Documentation directory.
>> So, my 1st question where do I get some informations in general on
>> this topic - usb [1] or net subdirectory (seen from kernel-side)?
>> I found a usb-serial kernel-doc [1].
>> ( I have no Linux Git source so I cannot grep for patterns. )
>
> None of those really have any information about WWAN specific setup, and
> I fear that if documentation was added, it would be quickly out-of-date
> because device manufacturers change things so frequently.
>

Anyway as said above a brief documentation would be nice.
Dunno placed below "networking" or "usb" - what is your POV?

>> The next mystery is what is network-manager doing in the background?
>> I have seen that modem-manager is invoked, but as said I would like to
>> understand the "internas" (means check the logs, turn on some
>> debugging kernel-space/user-space, etc.).
>
> NetworkManager uses ModemManager for all WWAN control, NM only handles
> the configuration storage and IP addressing parts of the setup.
> ModemManager handles modem hardware detection, capability detection,
> WWAN registration and setup, signal strength reporting, network
> connection initiation, and bearer IP addressing method determination.
>

Hmm, as I have a GUI hiding what's going on behind the scenes :-), I
wanted to have a step-by-step understanding - not only in words - also
understanding my logs.

What about putting this section in sth. like a "(General Overview:)
Userland software".

> If you want more information from ModemManager, you can run "mmcli
> --help" or "mmcli --set-logging=debug".
>

That sort of information could be placed in a "Debugging (userland)" section.
Or at least with some links to what Alexander pointed to.

What sort of debugging can I do from kernel-side (-> "Debugging kernel-side")?

>> I am not sure but syncing with 3G network seems to take a while since
>> I really can connect to the Internet.
>
> What do you mean by "syncing"?
>

"Syncing" means here setting up my Internet 3G (PPP) connection or
more precisely after I plugin my USB Internet-stick (usable in my
Linux OS) it takes some time to check for the next 2G/3G "attenna
tower" or "receiver/transmitter mast" (translation according to
<dict.leo.org>).
Checking my dmesg...
My eth0 is setup within 25secs and ready to receive/send from/to my
network-interface, whereas my PPP connection around 72secs.
As I have no automatic dialin selected in NM, I have to activate...
* 1st "mobile broadband"
* and then select the (provider) profile in a second step
So we are talking about 1 minute after login into my desktop, I can
live with that.
What I had in mind is... How can I accelerate/speedup (and establish)
an Internet 3G connection.

If you can give me your guidance, I am willing to write down a 1st
draft of a "usb-wwan-networking" documentation (currently I am really
busy with daily life and I hope I find some minutes).
I am looking for a "YES, I will." :-).

Regards.
- Sedat -
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
