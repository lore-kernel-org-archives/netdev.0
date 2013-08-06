From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Tue, 6 Aug 2013 23:40:31 +0200
Message-ID: <CA+icZUVk1HM-VVYcARvY7p5KBYz0YcY9+rW8s-nKPTeVYh4tgw@mail.gmail.com>
References: <1375804998.8219.27.camel@jlt4.sipsolutions.net>
	<CA+icZUVRgVfXUdJ1xoaN=nciqZDhV-f6EbH+6DS7HAh+My65oQ@mail.gmail.com>
	<CA+icZUUmQbovkwXcdEp6eu=WJkiuiyO8nDVwCHFUuPDbJqU7Kg@mail.gmail.com>
	<CA+icZUV++2+OG=P1SVbNrpHPLyzrfFX0eu8NHrd0nPjkPDUOtQ@mail.gmail.com>
	<CA+icZUXpZaHu-FjR6FGnbkG0XEkiukEgYYbDmrSjdqNz4rWCNg@mail.gmail.com>
	<1375816128.8219.28.camel@jlt4.sipsolutions.net>
	<CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com>
	<1375816715.8219.29.camel@jlt4.sipsolutions.net>
	<CA+icZUXdAjEDgu2XrA4Dg2hsLDJYdFTCpJwiW6=ZUgULe2noyw@mail.gmail.com>
	<CA+icZUVmokQ1fKmtbuPyp7f5Z2wdFYfjG5HCAm4Kue7efyKV8w@mail.gmail.com>
	<20130806213006.078C72210F@mail.nwl.cc>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b45105e323c9204e34e4608
To: Sedat Dilek <sedat.dilek@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	wireless <linux-wireless@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:60669 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592Ab3HFVkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 17:40:33 -0400
In-Reply-To: <20130806213006.078C72210F@mail.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b45105e323c9204e34e4608
Content-Type: text/plain; charset=UTF-8

On Tue, Aug 6, 2013 at 11:29 PM, Phil Sutter <phil@nwl.cc> wrote:
> On Tue, Aug 06, 2013 at 09:47:01PM +0200, Sedat Dilek wrote:
>> On Tue, Aug 6, 2013 at 9:32 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>> > On Tue, Aug 6, 2013 at 9:18 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
>> >> On Tue, 2013-08-06 at 21:14 +0200, Sedat Dilek wrote:
>> >>> On Tue, Aug 6, 2013 at 9:08 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
>> >>> > On Tue, 2013-08-06 at 20:35 +0200, Sedat Dilek wrote:
>> >>> >
>> >>> >> Attached is a diff comparing all new commits in next-20130805.
>> >>> >> If one of the commits smells bad to you, please let me know.
>> >>> >
>> >>> > Out of that list, only the af_packet changes would seem to have any
>> >>> > impact on wireless at all.
>> >>> >
>> >>>
>> >>> git-bisecting... 2 steps to go...
>> >>>
>> >>> This one is bad... "af_packet: simplify VLAN frame check in packet_snd"
>> >>>
>> >>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c483e02614551e44ced3fe6eedda8e36d3277ccc
>> >>
>> >> That seems weird, does reverting it fix it?
>> >>
>> >
>> > [ TO Phil Sutter ]
>> >
>> > This was 3/3 of af_packet patches :-).
>> >
>> > So, the culprit commit is...
>> >
>> > 0f75b09c798ed00c30d7d5551b896be883bc2aeb is the first bad commit
>> > commit 0f75b09c798ed00c30d7d5551b896be883bc2aeb
>> > Author: Phil Sutter <phil@nwl.cc>
>> > Date:   Fri Aug 2 11:37:39 2013 +0200
>> >
>> >     af_packet: when sending ethernet frames, parse header for skb->protocol
>> >
>> >     This may be necessary when the SKB is passed to other layers on the go,
>> >     which check the protocol field on their own. An example is a VLAN packet
>> >     sent out using AF_PACKET on a bridge interface. The bridging code checks
>> >     the SKB size, accounting for any VLAN header only if the protocol field
>> >     is set accordingly.
>> >
>> >     Note that eth_type_trans() sets skb->dev to the passed argument, so this
>> >     can be skipped in packet_snd() for ethernet frames, as well.
>> >
>> >     Signed-off-by: Phil Sutter <phil@nwl.cc>
>> >     Signed-off-by: David S. Miller <davem@davemloft.net>
>> >
>> > :040000 040000 af403a20a321517f6cfb51d2e22c17ca5a60e947
>> > 1f302ebd62a87b9e874a3e61203499e17d6fce3c M      net
>> >
>> > - Sedat -
>>
>> [ net/packet/af_packet.c ]
>> ...
>> #include <linux/if_arp.h>
>>
>> $ find include/ -name if_arp.h
>> include/uapi/linux/if_arp.h
>> include/linux/if_arp.h
>>
>> $ LC_ALL=C ll include/uapi/linux/if_arp.h include/linux/if_arp.h
>> -rw-r--r-- 1 wearefam wearefam 1560 Jul 11 19:42 include/linux/if_arp.h
>> -rw-r--r-- 1 wearefam wearefam 6344 Jul 26 12:36 include/uapi/linux/if_arp.h
>>
>> $ grep ARPHRD_ETHER include/linux/if_arp.h include/uapi/linux/if_arp.h
>> include/uapi/linux/if_arp.h:#define ARPHRD_ETHER        1
>>  /* Ethernet 10Mbps              */
>>
>> Wrong include?
>
> Nope, <linux/if_arp.h> includes <uapi/linux/if_arp.h>. I suppose there
> is a semantical problem here.
>
> Did you verify your bisect by reverting just the three patches?
>
> Does the problem occur on client or server side? AFAICT, hostapd as well
> as wpa_supplicant use AF_PACKET.
>
> The tricky thing is, these patches are meant to *loosen* the
> restrictions in af_packet.c, so *should* not be harmful. So either my
> patches create a side effect I did not foresee, or it's something nasty
> (too much delay introduced by calling eth_type_trans() or so).
>
> Could you please provide steps on how to reproduce the faulty behaviour?
>

By reverting the culprit commit my network/wifi is fine, again.
See also attached patch with changelog.

- Sedat -

--047d7b45105e323c9204e34e4608
Content-Type: application/octet-stream;
	name="0001-Revert-af_packet-when-sending-ethernet-frames-parse-.patch"
Content-Disposition: attachment;
	filename="0001-Revert-af_packet-when-sending-ethernet-frames-parse-.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hk1msyom0

RnJvbSA4MmQ4ZjU1Y2VhYjAwYzllZjgyOTE5NWU0NTRhOWNkNzRmZGVkMTY2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwuY29tPgpE
YXRlOiBUdWUsIDYgQXVnIDIwMTMgMjM6MDM6NTcgKzAyMDAKU3ViamVjdDogW1BBVENIIG5leHQt
MjAxMzA4MDVdIFJldmVydCAiYWZfcGFja2V0OiB3aGVuIHNlbmRpbmcgZXRoZXJuZXQKIGZyYW1l
cywgcGFyc2UgaGVhZGVyIGZvciBza2ItPnByb3RvY29sIgoKVGhpcyByZXZlcnRzIGNvbW1pdCAw
Zjc1YjA5Yzc5OGVkMDBjMzBkN2Q1NTUxYjg5NmJlODgzYmMyYWViCigiYWZfcGFja2V0OiB3aGVu
IHNlbmRpbmcgZXRoZXJuZXQgZnJhbWVzLCBwYXJzZSBoZWFkZXIgZm9yIHNrYi0+cHJvdG9jb2wi
KS4KCkkgbm90aWNlZCB3aXRoIG5leHQtMjAxMzA4MDYgdGhhdCBJIGNhbm5vdCBjb25uZWN0IHRv
IG15IFdMQU4tQVAgYW55bW9yZS4KbmV4dC0yMDEzMDgwMiB3YXMgdGhlIGxhc3QgR09PRCBhbmQg
bmV4dC0yMDEzMDgwNSB0aGUgZmlyc3QgQkFEIExpbnV4LW5leHQKcmVsZWFzZS4KCkRlYnVnZ2lu
ZyB3aXRoIHdwYXN1cHBsaWNhbnQgZGlkIG5vdCBzaG93IGFueSBpbmNvbnNpc3RlbmN5LgpUbyBl
bnN1cmUgaXQgaXMgbm90IGEgcHJvYmxlbSBvZiB3aXJlbGVzcywgSSB0cmllZCB3aXJlbGVzcy10
ZXN0aW5nCihtYXN0ZXItMjAxMy0wOC0wNSksIHdoaWNoIGRpZCBub3Qgc2hvdyB0aGUgc3ltcHRv
bXMuClRoYW5rcyBKb2hhbm5lcyBCZXJnIGZvciB0aGUgdml0YWwgaGVscC4KCkFmdGVyIGEgZ2l0
LWJpc2VjdCBzZXNzaW9uIGl0IHR1cm5lZCBvdXQgdGhhdCB0aGUgYWJvdmUgY29tbWl0IGlzIHRo
ZQpjdWxwcml0LgoKUmV2ZXJ0aW5nIGl0IGZpeGVzIHRoZSBpc3N1ZSBmb3IgbWUuCgpBZGFwdGVk
IGFuZCB0ZXN0ZWQgYWdhaW5zdCBMaW51eC1uZXh0IChuZXh0LTIwMTMwODA1KS4KClNpZ25lZC1v
ZmYtYnk6IFNlZGF0IERpbGVrIDxzZWRhdC5kaWxla0BnbWFpbC5jb20+Ci0tLQogbmV0L3BhY2tl
dC9hZl9wYWNrZXQuYyB8IDE1ICsrLS0tLS0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDIgaW5z
ZXJ0aW9ucygrKSwgMTMgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0L3BhY2tldC9hZl9w
YWNrZXQuYyBiL25ldC9wYWNrZXQvYWZfcGFja2V0LmMKaW5kZXggMGMwZjZjOS4uOTM0M2VhNyAx
MDA2NDQKLS0tIGEvbmV0L3BhY2tldC9hZl9wYWNrZXQuYworKysgYi9uZXQvcGFja2V0L2FmX3Bh
Y2tldC5jCkBAIC04OCw3ICs4OCw2IEBACiAjaW5jbHVkZSA8bGludXgvdmlydGlvX25ldC5oPgog
I2luY2x1ZGUgPGxpbnV4L2VycnF1ZXVlLmg+CiAjaW5jbHVkZSA8bGludXgvbmV0X3RzdGFtcC5o
PgotI2luY2x1ZGUgPGxpbnV4L2lmX2FycC5oPgogCiAjaWZkZWYgQ09ORklHX0lORVQKICNpbmNs
dWRlIDxuZXQvaW5ldF9jb21tb24uaD4KQEAgLTIwMDIsOSArMjAwMSw2IEBAIHN0YXRpYyBpbnQg
dHBhY2tldF9maWxsX3NrYihzdHJ1Y3QgcGFja2V0X3NvY2sgKnBvLCBzdHJ1Y3Qgc2tfYnVmZiAq
c2tiLAogCQlpZiAodW5saWtlbHkoZXJyKSkKIAkJCXJldHVybiBlcnI7CiAKLQkJaWYgKGRldi0+
dHlwZSA9PSBBUlBIUkRfRVRIRVIpCi0JCQlza2ItPnByb3RvY29sID0gZXRoX3R5cGVfdHJhbnMo
c2tiLCBkZXYpOwotCiAJCWRhdGEgKz0gZGV2LT5oYXJkX2hlYWRlcl9sZW47CiAJCXRvX3dyaXRl
IC09IGRldi0+aGFyZF9oZWFkZXJfbGVuOwogCX0KQEAgLTIzMzEsMjAgKzIzMjcsMTMgQEAgc3Rh
dGljIGludCBwYWNrZXRfc25kKHN0cnVjdCBzb2NrZXQgKnNvY2ssCiAKIAlzb2NrX3R4X3RpbWVz
dGFtcChzaywgJnNrYl9zaGluZm8oc2tiKS0+dHhfZmxhZ3MpOwogCi0JaWYgKGRldi0+dHlwZSA9
PSBBUlBIUkRfRVRIRVIpIHsKLQkJc2tiLT5wcm90b2NvbCA9IGV0aF90eXBlX3RyYW5zKHNrYiwg
ZGV2KTsKLQkJaWYgKHNrYi0+cHJvdG9jb2wgPT0gaHRvbnMoRVRIX1BfODAyMVEpKQotCQkJcmVz
ZXJ2ZSArPSBWTEFOX0hMRU47Ci0JfSBlbHNlIHsKLQkJc2tiLT5wcm90b2NvbCA9IHByb3RvOwot
CQlza2ItPmRldiA9IGRldjsKLQl9Ci0KIAlpZiAoIWdzb190eXBlICYmIChsZW4gPiBkZXYtPm10
dSArIHJlc2VydmUgKyBleHRyYV9sZW4pKSB7CiAJCWVyciA9IC1FTVNHU0laRTsKIAkJZ290byBv
dXRfZnJlZTsKIAl9CiAKKwlza2ItPnByb3RvY29sID0gcHJvdG87CisJc2tiLT5kZXYgPSBkZXY7
CiAJc2tiLT5wcmlvcml0eSA9IHNrLT5za19wcmlvcml0eTsKIAlza2ItPm1hcmsgPSBzay0+c2tf
bWFyazsKIAotLSAKMS44LjMuNAoK
--047d7b45105e323c9204e34e4608--
