From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH RFC] brcmfmac: support deleting MBSS AP interfaces
Date: Fri, 17 Jun 2016 21:00:16 +0200
Message-ID: <576448C0.4080102@broadcom.com>
References: <1464791845-23944-1-git-send-email-zajec5@gmail.com>
 <574F30D8.5000300@broadcom.com>
 <CACna6rzcfYu=3qoMsTCShHUWbpz-0-uWgogVLWJwiNv228PhPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list@broadcom.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37939 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbcFQTAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 15:00:20 -0400
Received: by mail-wm0-f53.google.com with SMTP id m124so538949wme.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 12:00:19 -0700 (PDT)
In-Reply-To: <CACna6rzcfYu=3qoMsTCShHUWbpz-0-uWgogVLWJwiNv228PhPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-16 14:30, Rafa=C5=82 Mi=C5=82ecki wrote:
> On 1 June 2016 at 21:00, Arend van Spriel <arend.vanspriel@broadcom.c=
om> wrote:
>> On 01-06-16 16:36, Rafa=C5=82 Mi=C5=82ecki wrote:
>>> We already support adding extra (AP) interfaces so it also makes an
>>> obvious sense to allow deleting them.
>>>
>>> Adding a new interface is implemented by sending request to firmwar=
e for
>>> creating a new BSS and waiting for a proper event. Ideally deleting
>>> interface should be handled in a similar way. There should be a req=
uest
>>> to firmware for deleting BSS and firmware should respond with an ev=
ent.
>>>
>>> Unfortunately it doesn't seem to work with recent firmwares. They n=
ever
>>> seem to delete BSS and never send BRCMF_E_IF_DEL. As a workaround t=
his
>>> patch deletes Linux interface while keeping a track of BSSes presen=
t in
>>> a firmware. If there is request for adding a new interface this cod=
e is
>>> capable of reusing existing BSS-es.
>>
>> It is not so much an issue of recent firmware. Actually, on recent
>> firmware 7.x.y.z and higher there are other command to create *and*
>> delete additional interfaces. On the other hand we aim to support a
>> large number of devices going back to bcm4329 so we have to come up =
with
>> a scheme to use the new commands or fallback to old api. Let's hope =
we
>> can reuse much of this effort you put in.
>=20
> You gave me a complex puzzle there :D It took me a while to find out
> what API you meant.

Actually, the puzzle was supposed to be for me, but I like your
curiosity and persistence in digging up the (partial) info.

> Finally I found an interesting wlioctl.h in SDK 9.10.178.27 that gave
> me some clue. I got this SDK from ASUS RT-AC1200G+ open souce tarball=
=2E
> There are 2 interesting structs:
>=20
> typedef struct wl_interface_create {
>         uint16 ver; /* version of this struct */
>         uint32  flags; /* flags that defines the operation */
>         struct ether_addr   mac_addr; /* Optional Mac address */
>         uint32  wlc_index; /* Optional wlc index */
> } wl_interface_create_t;
>=20
> typedef struct wl_interface_info {
>         uint16 ver; /* version of this struct */
>         struct ether_addr    mac_addr; /* MAC address of the interfac=
e */
>         char ifname[BCM_MSG_IFNAME_MAX]; /* name of interface */
>         uint8 bsscfgidx; /* source bsscfg index */
> } wl_interface_info_t;
>=20
> I couldn't find any corresponding WLC_* in wlioctl_defs.h, so I guess
> I should use WLC_SET_VAR (or WLC_SET_VAR as you prefer) with some

(huh)? anyway the api indeed uses what we call an iovar, ie.
string-based ioctl.

> string. Any tip what would it be? Something like
> "wl_interface_create"? Can you reveal such a small secret?

It is "interface_create" and "interface_remove".

Regards,
Arend
