From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [net-next] ppp: rtnetlink device handling
Date: Thu, 31 Dec 2015 13:03:50 +0100
Message-ID: <CA+icZUWSytUFWPJ43Da-Kkct=B75JfoQLx8608gJ=mxaCSyeww@mail.gmail.com>
References: <CA+icZUVb03kO3O2nqEHazotM_Df4SLUw6SOAuPXuB3eNy_gOHg@mail.gmail.com>
	<20151231104147.GM18510@alphalink.fr>
	<CA+icZUU5z_sgYTOSBGazJU9VSm6qZxfA=PXcRQ5bwj-7rOU6fQ@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11425c82a697c00528307213
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:32994 "EHLO
	mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbbLaMDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 07:03:51 -0500
Received: by mail-vk0-f45.google.com with SMTP id a188so216814666vkc.0
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2015 04:03:51 -0800 (PST)
In-Reply-To: <CA+icZUU5z_sgYTOSBGazJU9VSm6qZxfA=PXcRQ5bwj-7rOU6fQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11425c82a697c00528307213
Content-Type: text/plain; charset=UTF-8

On Thu, Dec 31, 2015 at 12:01 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Thu, Dec 31, 2015 at 11:41 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
>> On Thu, Dec 31, 2015 at 08:46:59AM +0100, Sedat Dilek wrote:
>>> Hi Guillaume,
>>>
>>> can you explain why you moved ppp to rtnetlink device handling?
>>> Benefits, etc.?
>>>
>> The objective is to bring all the flexibility of rtnetlink device
>> creation to ppp interfaces. This is particularly useful for Network
>> Access Servers which need to define device properties at creation
>> time. My use case includes setting device name and netns, which is
>> impossible with the ioctl-based interface without generating transient
>> effects.
>>
>
> What do you mean by "my use-case"?
> Example?
>
>>> Does anything change when using NetworkManager/ModemManager/pppd for
>>> my network setup/handling (here: Ubuntu/precise AMD64)?
>>>
>> No. The ioctl-based ABI remains unchanged, so programs using it won't
>> see any difference. The rtnl ABI only brings a new way to create PPP
>> devices.
>>
>> Whether a ppp device is created with the ioctl or rtnl ABI doesn't
>> change its behaviour. In particular ppp devices created with rtnl can
>> still be configured with the old ioctls. The only difference I can
>> think of, is that managing ppp devices with rtnl allows a user to
>> remove it with "ip link del", while this is not possible with ppp
>> devices created with ioctl.
>>
>
> That all sounds like an improvement.
>
>>> Thanks in advance.
>>>
>> You're welcome.
>>
>
> Building net-next-20151231 with your 3 patches on top...
>
> Guillaume Nault (8):
>       ppp: don't set sk_state to PPPOX_ZOMBIE in pppoe_disc_rcv()
>       ppp: remove PPPOX_ZOMBIE socket state
>       pppox: use standard module auto-loading feature
>       ppp: define "ppp" device type
>       ppp: declare ppp devices as enumerated interfaces
>       ppp: define reusable device creation functions <--- (1)
>       ppp: implement rtnetlink device handling <--- (2)
>       l2tp: rely on ppp layer for skb scrubbing <--- (3)
>
> ...will report.
>
> - Sedat -

# LC_ALL=C ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN mode DEFAULT qlen 1000
    link/ether e8:03:9a:36:17:a9 brd ff:ff:ff:ff:ff:ff
3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
DEFAULT qlen 1000
    link/ether 88:53:2e:ac:c3:12 brd ff:ff:ff:ff:ff:ff
4: wwan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
DEFAULT qlen 1000
    link/ether 02:50:f3:00:00:00 brd ff:ff:ff:ff:ff:ff
5: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast state UNKNOWN mode DEFAULT qlen 3
    link/ppp

- Sedat -

--001a11425c82a697c00528307213
Content-Type: application/x-sh; name="run_htb-with-fq_codel_ppp0.sh"
Content-Disposition: attachment; filename="run_htb-with-fq_codel_ppp0.sh"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iiu7eg2z0

IyEvYmluL3NoCgojIEhFTFAtMTogaHR0cDovL3d3dy5idWZmZXJibG9hdC5uZXQvcHJvamVjdHMv
Y29kZWwvd2lraS9XaWtpCiMgSEVMUC0yOiBodHRwOi8vd3d3LmJ1ZmZlcmJsb2F0Lm5ldC9wcm9q
ZWN0cy9jb2RlbC93aWtpL0hPV1RPCgojIFBSRVJFUS0xOiBMaW51eC1rZXJuZWwgd2l0aCBDT0RF
TC9GUV9DT0RFTCBzdXBwb3J0IGVuYWJsZWQgKEJRTCBmb3IgR2lnRSBuZXR3b3JrIGNhcmRzKQoj
IFBSRVJFUS0yOiBpcHJvdXRlMiB3aXRoIENPREVML0ZRX0NPREVMIHN1cHBvcnQKIwojIE5PVEUt
MTogTGludXgta2VybmVsID49djMuNS1yYzEgb3IgYmFja3BvcnRlZCBwYXRjaHNldCBmb3IgdjMu
My54L3YzLjQueAojIE5PVEUtMjogaXByb3V0ZSBwYWNrYWdlcyBmcm9tIERlYmlhbi9leHBlcmlt
ZW50YWwgb3IgS2FtYWwgTW9zdGFmYSdzIGJ1ZmZlcmJsb2F0IFBQQSBhcmNoaXZlCiMKIyBJTlNU
QUxMOiAKCiMgTGFuZ3VhZ2Ugc2V0dGluZ3MKZXhwb3J0IExBTkc9QwpleHBvcnQgTENfQUxMPUMK
CiMgTmV0d29yayBpbnRlcmZhY2UgKGhlcmU6IE1vYmlsZS1Ccm9hZGJhbmQgM0cgKFVNVFMvSFNQ
QSkgb24gVWJ1bnR1L3ByZWNpc2UpCmlmYWNlPSJwcHAwIgoKIyBteUlTUDogSHVhd2VpIEUxNzMg
d2l0aCBBbGRpVGFsayAoTWVkaW9uTW9iaWxlIGFrYSBFLVBsdXMpOiBIU1VQQSA1LDc2IGFuZCBI
U0RQQSA3LDIgW01CaXQvc10KdXBsaW5rPTU4OTgKZG93bmxpbms9NzM3MwoKIyBMb2FkIGFuZCBs
aXN0IEhUQiBhbmQgRlFfQ09ERUwgbmV0d29yayBzY2hlZHVsZXIgbW9kdWxlcwptb2Rwcm9iZSAt
diBzY2hfaHRiCm1vZHByb2JlIC12IHNjaF9mcV9jb2RlbApsc21vZCB8IHNvcnQgfCBncmVwIF5z
Y2hfCgojIERlbGV0ZSBhbnkgZXhpc3Rpbmcgcm9vdCBxZGlzYyBhc3NpZ25tZW50cwp0YyBxZGlz
YyBkZWwgZGV2ICR7aWZhY2V9IHJvb3QKCiMgUm9vdCBxZGlzYyAoaGVyZTogSFRCKSBxZGlzYyBw
YXJhbWV0ZXJzCnRjIHFkaXNjIGFkZCBkZXYgJHtpZmFjZX0gcm9vdCBoYW5kbGUgMTogaHRiIGRl
ZmF1bHQgMQoKIyBSb290IHFkaXNjIChoZXJlOiBIVEIpIGNsYXNzIHBhcmFtZXRlcnMgKGhlcmU6
IGxpbWl0IHVwbGluayByYXRlKQp0YyBjbGFzcyBhZGQgZGV2ICR7aWZhY2V9IHBhcmVudCAxOiBj
bGFzc2lkIDE6MSBodGIgcmF0ZSAke3VwbGlua31rYml0CgojIExlYWYgcWRpc2MgKGhlcmU6IEZR
X0NPREVMKSBxZGlzYyBwYXJhbWV0ZXJzCnRjIHFkaXNjIGFkZCBkZXYgJHtpZmFjZX0gcGFyZW50
IDE6MSBoYW5kbGUgMTE6IGZxX2NvZGVsCgojIFNob3cgYWxsIHFkaXNjIGFuZCBjbGFzcyBhc3Np
Z25tZW50cwp0YyBxZGlzYyBzaG93IGRldiAke2lmYWNlfQp0YyBjbGFzcyBzaG93IGRldiAke2lm
YWNlfQoKIyBMaXN0IGxvYWRlZCBuZXR3b3JrIHNjaGVkdWxlciBtb2R1bGVzIGFnYWluIChhZnRl
ciB0YyBhc3NpZ25tZW50czogIjAiIC0+ICIxIikKbHNtb2QgfCBzb3J0IHwgZ3JlcCBec2NoXwo=
--001a11425c82a697c00528307213--
