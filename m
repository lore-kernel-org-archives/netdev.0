From: YanBo <dreamfly281-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Regression in 3.9 caused by "bridge: respect RFC2863 operational state"
Date: Tue, 19 Jan 2016 13:10:51 -0800
Message-ID: <CAFuUQkgCvS6+1+3YRhBMLt3i5vvJh1SQ6EG_pe07AD14TssSrg@mail.gmail.com>
References: <CAFuUQkhHsRZMnNYBbVZU0=BcAKMEktzYgPv6oc=CMFd7MFDi6g@mail.gmail.com>
	<CAFuUQkjm3RFnrzWWSvbnYFC8gMnbX7C4bP_x0+2bREYumcoJyg@mail.gmail.com>
	<439966a35f064c7690f2ccbe7296c552@aphydexm01b.ap.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org" <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	"Malinen, Jouni" <jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	"kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Krishna Chaitanya <chaitanya.mgit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sebastian Gottschall <s.gottschall-t37Kgv3TaIPQT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"hostap-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <hostap-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: "Shajakhan, Mohammed Shafi (Mohammed Shafi)"
	<mohammed-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <439966a35f064c7690f2ccbe7296c552-uFOy1J/eYsFdSXZW2pRUXqRtKmQZhJ7pQQ4Iyu8u01E@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is a fixing in
http://git.openwrt.org/?p=openwrt.git;a=blob_plain;f=target/linux/generic/patches-4.3/120-bridge_allow_receiption_on_disabled_port.patch
for your reference.

Yanbo

On Tue, Jan 19, 2016 at 7:45 AM, Shajakhan, Mohammed Shafi (Mohammed
Shafi) <mohammed-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org> wrote:
> Hi all,
>
> Any updates on this please.
>
> Thanks,
> shafi
>
> -----Original Message-----
> From: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of YanBo
> Sent: Friday, December 04, 2015 8:01 AM
> To: nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org; Malinen, Jouni; kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
> Cc: Stephen Hemminger; Krishna Chaitanya; linux-wireless; Sebastian Gottschall; Johannes Berg; netdev; hostap-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> Subject: Re: Regression in 3.9 caused by "bridge: respect RFC2863 operational state"
>
>  Sorry to pick up this thread again,  it looks this issue still existed  in the newer 4.3 kernel. (The EAP frames can not be received by wireless interface due to the bridge interface,
> http://marc.info/?l=linux-wireless&m=136743495526905&w=2)
>
>  Wonder is anyone know some update for this issue?  Currently the only workaround is make the 4-address  AP and STA associated in security mode firstly and then create the bridge, the renew key configuration also need be disable at the hostapd side to  avoid renew the key at bridge status.
>
> Thanks
> Yanbo
>> On Wed, May 1, 2013 at 5:53 PM, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org> wrote:
>> >
>> > On 2013-05-02 12:49 AM, Stephen Hemminger wrote:
>> > > On Wed, 01 May 2013 23:06:16 +0200 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
>> > > wrote:
>> > >
>> > >> On 2013-05-01 10:21 PM, Stephen Hemminger wrote:
>> > >> > What about using AF_PACKET bound to underlying wireless device
>> > >> > and the packet type. You can even use BPF to filter.
>> > >> As far as I know, AF_PACKET only works when not binding it to the
>> > >> packet type (otherwise it get stolen by the rx handler).
>> > >
>> > > You can do AF_PACKET and it gets handle before rx_handler.
>> > If I don't bind it to a protocol, it ends up in ptype_all, if I do,
>> > it ends up in &ptype_base. ptype_all is processed before the
>> > rx_handler, ptype_base is processed after the rx handler.
>> > Hooking into ptype_all wastes tons of CPU cycles, hooking into
>> > ptype_base does not solve the problem.
>> >
>> > - Felix
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe
>> > linux-wireless" in the body of a message to
>> > majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org More majordomo info at
>> > http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
