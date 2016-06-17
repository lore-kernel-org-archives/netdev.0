From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH RFC] brcmfmac: support deleting MBSS AP interfaces
Date: Fri, 17 Jun 2016 14:30:47 +0200
Message-ID: <CACna6rzcfYu=3qoMsTCShHUWbpz-0-uWgogVLWJwiNv228PhPQ@mail.gmail.com>
References: <1464791845-23944-1-git-send-email-zajec5@gmail.com> <574F30D8.5000300@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <574F30D8.5000300@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1 June 2016 at 21:00, Arend van Spriel <arend.vanspriel@broadcom.com=
> wrote:
> On 01-06-16 16:36, Rafa=C5=82 Mi=C5=82ecki wrote:
>> We already support adding extra (AP) interfaces so it also makes an
>> obvious sense to allow deleting them.
>>
>> Adding a new interface is implemented by sending request to firmware=
 for
>> creating a new BSS and waiting for a proper event. Ideally deleting
>> interface should be handled in a similar way. There should be a requ=
est
>> to firmware for deleting BSS and firmware should respond with an eve=
nt.
>>
>> Unfortunately it doesn't seem to work with recent firmwares. They ne=
ver
>> seem to delete BSS and never send BRCMF_E_IF_DEL. As a workaround th=
is
>> patch deletes Linux interface while keeping a track of BSSes present=
 in
>> a firmware. If there is request for adding a new interface this code=
 is
>> capable of reusing existing BSS-es.
>
> It is not so much an issue of recent firmware. Actually, on recent
> firmware 7.x.y.z and higher there are other command to create *and*
> delete additional interfaces. On the other hand we aim to support a
> large number of devices going back to bcm4329 so we have to come up w=
ith
> a scheme to use the new commands or fallback to old api. Let's hope w=
e
> can reuse much of this effort you put in.

You gave me a complex puzzle there :D It took me a while to find out
what API you meant.

=46inally I found an interesting wlioctl.h in SDK 9.10.178.27 that gave
me some clue. I got this SDK from ASUS RT-AC1200G+ open souce tarball.
There are 2 interesting structs:

typedef struct wl_interface_create {
        uint16 ver; /* version of this struct */
        uint32  flags; /* flags that defines the operation */
        struct ether_addr   mac_addr; /* Optional Mac address */
        uint32  wlc_index; /* Optional wlc index */
} wl_interface_create_t;

typedef struct wl_interface_info {
        uint16 ver; /* version of this struct */
        struct ether_addr    mac_addr; /* MAC address of the interface =
*/
        char ifname[BCM_MSG_IFNAME_MAX]; /* name of interface */
        uint8 bsscfgidx; /* source bsscfg index */
} wl_interface_info_t;

I couldn't find any corresponding WLC_* in wlioctl_defs.h, so I guess
I should use WLC_SET_VAR (or WLC_SET_VAR as you prefer) with some
string. Any tip what would it be? Something like
"wl_interface_create"? Can you reveal such a small secret?

Also can you share any tip on removing interface? I don't see any
struct for that. Is that handled by some special value in
"wl_interface_create_t" or by separated string used with WLC_SET_VAR?
