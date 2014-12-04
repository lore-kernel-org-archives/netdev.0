From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 4 Dec 2014 13:28:24 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412041326160.9926@gmail.com>
References: <AMSPR06MB6011E001029C251790CB923EE780@AMSPR06MB601.eurprd06.prod.outlook.com> <877fy7myfb.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-735099337-1417696107=:9926"
Cc: Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877fy7myfb.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-735099337-1417696107=:9926
Content-Type: TEXT/PLAIN; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8BIT

... DHCP will work with some DHCPNACKS in the meanwhile, but ping stops working at all.
Otherwise, it works with the standard value:

--- 8.8.8.8 ping statistics ---
48 packets transmitted, 48 received, 0% packet loss, time 47004ms
rtt min/avg/max/mdev = 362.084/392.878/523.132/33.636 ms

And I was expecting effectively to see some lost packets, but instead... no.


On Thu, 4 Dec 2014, Bjørn Mork wrote:

> Date: Thu, 4 Dec 2014 12:44:56
> From: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> To: Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
> Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>     Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>     Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>     Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>     "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>     "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
>     "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Subject: Re: Is this 32-bit NCM?y
> 
> "Midge Shaojun  Tan" <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org> writes:
>
>> Hi all,
>>
>> I test OK with kervel 3.16.4
>> Need disable other Ethernet network, just like eth1. (Then the DNS and route is OK)
>> And also need disable arp, (ifconfig wwan0 -arp up), because China UNICOM don't respond the ARP message.
>
> The ARP functionality is independent of operator.  It is handled
> internally by the modem firmware.  There are no MAC addresses or
> ethernet headers transmitted over the radio link.  That's all faked by
> the modem.  All MAC addresses and ethernet headers are local to the
> modem<->host USB link.
>
>> With new mode switch string: /etc/usb_modeswitch.d/12d1:14fe
>> Please see the patch and check whether it is correct?
>
> I see that you have two changes there:
>
> 1) the ETH_HLEN adjustment of ctx->tx_remainder is dropped
> 2) the NDP is placed after the first frame.
>
> I haven't verified the effect of the tx_remainder change, but I assume
> it fixes an alignment problem for this device.  I'd like to look more at
> the effect of this for different values of wNdpOutPayloadRemainder and
> wNdpOutDivisor.
>
> We can choose to put the NDP at the end of the NTB if we find that this
> fixes some problem, but doing so by default for every NCM and MBIM
> device is a bit risky. If we accept that some devices are so buggy that
> the NDP cannot be placed anywhere (as required by the spec), then we
> have to assume that this goes both ways.  Which means that moving the
> NDP to the end of the NTB might break some other device.  We just don't
> know that since we haven't ever tried it.
>
> And your fix doesn't really move it to the end either.  It just places
> the NDP after the first ethernet packet.  Which happens to be the end if
> there is only one packet in the NTB. But if we aggregate more packets
> into this NTB then the result will look like this:
>
> NTH
> eth packet 1
> NDP
> eth packet 2
> ..
> eth packet N
>
> I'm not convinced this modem will handle that if it cannot handle the
> NDP being before the first packet...  This needs to be tested.  Try
> increasing /sys/class/net/wwan0/cdc_ncm/tx_timer_usecs to force the
> driver to aggregate packets and see if everything still works.
> Preferably while looking at the resulting NTB to verify that it does
> contain more than one ethernet packet.
>
> I realize I sound a bit negative now.  This is absolutely not my
> intention. This is great work, providing some real progress wrt figuring
> out what goes on here.  Thanks a lot!  I am sure we can sort out the
> remaining issues, which are really minor compared to what you have found
> so far.
>
>
>
> Bjørn
>
>
--8323328-735099337-1417696107=:9926--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
