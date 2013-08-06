From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Tue, 6 Aug 2013 21:32:26 +0200
Message-ID: <CA+icZUXdAjEDgu2XrA4Dg2hsLDJYdFTCpJwiW6=ZUgULe2noyw@mail.gmail.com>
References: <CA+icZUX8OcTSOABO6Nbz5R6_5-m39rsYOpDqYBA7hf8LFvJLLA@mail.gmail.com>
	<1375797260.8219.21.camel@jlt4.sipsolutions.net>
	<CA+icZUUAJ25QybqHvxz7eubSLH6YuNjcc5zyU2O5Xi9vevMGkw@mail.gmail.com>
	<1375800617.8219.23.camel@jlt4.sipsolutions.net>
	<CA+icZUVbKpyuke6PRg3-60gOggsTb=3cNRz3Sy0RmvcZSuPaNw@mail.gmail.com>
	<1375801059.8219.24.camel@jlt4.sipsolutions.net>
	<CA+icZUXrRsXfeW9hqxTMkKW4TdNSBH-zE8-zX2Rd7HTAx5MvqQ@mail.gmail.com>
	<CA+icZUWijPJmNoqE22Msqcn7tRot3SB3e=KujMM7JNd-Om-oOw@mail.gmail.com>
	<1375802297.8219.25.camel@jlt4.sipsolutions.net>
	<CA+icZUVCFOS6SHonEqzaJyWCGCU4nqqGjBN0VbmV-=OoM+deZg@mail.gmail.com>
	<CA+icZUVuOqdZUGy2ALAF1CehOqYdr7rtEsXhqNvDtYEns2BuRQ@mail.gmail.com>
	<1375802993.8219.26.camel@jlt4.sipsolutions.net>
	<CA+icZUW6P9Z_7z+o+z=qBWSFzyU8tgtY0ou+rmLcEzWbn94OXA@mail.gmail.com>
	<CA+icZUW7LVzg7sM3O-w5oQpeaj=CT6MS6Q7cRZ1qK0h-Z4wZuw@mail.gmail.com>
	<1375804998.8219.27.camel@jlt4.sipsolutions.net>
	<CA+icZUVRgVfXUdJ1xoaN=nciqZDhV-f6EbH+6DS7HAh+My65oQ@mail.gmail.com>
	<CA+icZUUmQbovkwXcdEp6eu=WJkiuiyO8nDVwCHFUuPDbJqU7Kg@mail.gmail.com>
	<CA+icZUV++2+OG=P1SVbNrpHPLyzrfFX0eu8NHrd0nPjkPDUOtQ@mail.gmail.com>
	<CA+icZUXpZaHu-FjR6FGnbkG0XEkiukEgYYbDmrSjdqNz4rWCNg@mail.gmail.com>
	<1375816128.8219.28.camel@jlt4.sipsolutions.net>
	<CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com>
	<1375816715.8219.29.camel@jlt4.sipsolutions.net>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f46d043bdfde24120404e34c7c07
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	wireless <linux-wireless@vger.kernel.org>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:49677 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755780Ab3HFTc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 15:32:28 -0400
In-Reply-To: <1375816715.8219.29.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--f46d043bdfde24120404e34c7c07
Content-Type: text/plain; charset=UTF-8

On Tue, Aug 6, 2013 at 9:18 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Tue, 2013-08-06 at 21:14 +0200, Sedat Dilek wrote:
>> On Tue, Aug 6, 2013 at 9:08 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
>> > On Tue, 2013-08-06 at 20:35 +0200, Sedat Dilek wrote:
>> >
>> >> Attached is a diff comparing all new commits in next-20130805.
>> >> If one of the commits smells bad to you, please let me know.
>> >
>> > Out of that list, only the af_packet changes would seem to have any
>> > impact on wireless at all.
>> >
>>
>> git-bisecting... 2 steps to go...
>>
>> This one is bad... "af_packet: simplify VLAN frame check in packet_snd"
>>
>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c483e02614551e44ced3fe6eedda8e36d3277ccc
>
> That seems weird, does reverting it fix it?
>

[ TO Phil Sutter ]

This was 3/3 of af_packet patches :-).

So, the culprit commit is...

0f75b09c798ed00c30d7d5551b896be883bc2aeb is the first bad commit
commit 0f75b09c798ed00c30d7d5551b896be883bc2aeb
Author: Phil Sutter <phil@nwl.cc>
Date:   Fri Aug 2 11:37:39 2013 +0200

    af_packet: when sending ethernet frames, parse header for skb->protocol

    This may be necessary when the SKB is passed to other layers on the go,
    which check the protocol field on their own. An example is a VLAN packet
    sent out using AF_PACKET on a bridge interface. The bridging code checks
    the SKB size, accounting for any VLAN header only if the protocol field
    is set accordingly.

    Note that eth_type_trans() sets skb->dev to the passed argument, so this
    can be skipped in packet_snd() for ethernet frames, as well.

    Signed-off-by: Phil Sutter <phil@nwl.cc>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 af403a20a321517f6cfb51d2e22c17ca5a60e947
1f302ebd62a87b9e874a3e61203499e17d6fce3c M      net

- Sedat -

--f46d043bdfde24120404e34c7c07
Content-Type: text/plain; charset=US-ASCII; name="git-bisect-log.txt"
Content-Disposition: attachment; filename="git-bisect-log.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hk1i8k5o0

Z2l0IGJpc2VjdCBzdGFydAojIGdvb2Q6IFs4ODgyNWM3MGQ0Nzk1M2U3ZjM4Yjg2ZmIyZWYwMDYy
MzQzOTIxN2QwXSBNZXJnZSByZW1vdGUtdHJhY2tpbmcgYnJhbmNoICd3aXJlbGVzcy9tYXN0ZXIn
CmdpdCBiaXNlY3QgZ29vZCA4ODgyNWM3MGQ0Nzk1M2U3ZjM4Yjg2ZmIyZWYwMDYyMzQzOTIxN2Qw
CiMgZ29vZDogWzM1ODBkMjQzOTcwMmZhMjllZmNiY2U5ZTJiYjFiY2ViMjY4OGQzNTJdIE1lcmdl
IHJlbW90ZS10cmFja2luZyBicmFuY2ggJ3NsYXZlLWRtYS9uZXh0JwpnaXQgYmlzZWN0IGdvb2Qg
MzU4MGQyNDM5NzAyZmEyOWVmY2JjZTllMmJiMWJjZWIyNjg4ZDM1MgojIGdvb2Q6IFs4ODgyNWM3
MGQ0Nzk1M2U3ZjM4Yjg2ZmIyZWYwMDYyMzQzOTIxN2QwXSBNZXJnZSByZW1vdGUtdHJhY2tpbmcg
YnJhbmNoICd3aXJlbGVzcy9tYXN0ZXInCmdpdCBiaXNlY3QgZ29vZCA4ODgyNWM3MGQ0Nzk1M2U3
ZjM4Yjg2ZmIyZWYwMDYyMzQzOTIxN2QwCiMgZ29vZDogWzM1ODBkMjQzOTcwMmZhMjllZmNiY2U5
ZTJiYjFiY2ViMjY4OGQzNTJdIE1lcmdlIHJlbW90ZS10cmFja2luZyBicmFuY2ggJ3NsYXZlLWRt
YS9uZXh0JwpnaXQgYmlzZWN0IGdvb2QgMzU4MGQyNDM5NzAyZmEyOWVmY2JjZTllMmJiMWJjZWIy
Njg4ZDM1MgojIGdvb2Q6IFthNTk0ZTRmOGMzMWM0MDAwMjQyOTNiMmU5N2ZjN2QzZmFhYWU3NGRh
XSBNZXJnZSBicmFuY2ggJ2JvbmRfcmN1JwpnaXQgYmlzZWN0IGdvb2QgYTU5NGU0ZjhjMzFjNDAw
MDI0MjkzYjJlOTdmYzdkM2ZhYWFlNzRkYQojIGJhZDogWzdmODQ2MjJiOWFjNzQxNjE0ZTdkMDY2
ZjdlODUxMWQwNTRmNTEzZWNdIE1lcmdlIHJlbW90ZS10cmFja2luZyBicmFuY2ggJ25ldC1uZXh0
L21hc3RlcicKZ2l0IGJpc2VjdCBiYWQgN2Y4NDYyMmI5YWM3NDE2MTRlN2QwNjZmN2U4NTExZDA1
NGY1MTNlYwojIGJhZDogW2M0ODNlMDI2MTQ1NTFlNDRjZWQzZmU2ZWVkZGE4ZTM2ZDMyNzdjY2Nd
IGFmX3BhY2tldDogc2ltcGxpZnkgVkxBTiBmcmFtZSBjaGVjayBpbiBwYWNrZXRfc25kCmdpdCBi
aXNlY3QgYmFkIGM0ODNlMDI2MTQ1NTFlNDRjZWQzZmU2ZWVkZGE4ZTM2ZDMyNzdjY2MKIyBnb29k
OiBbZTIxNjk3NWFkOTdjZmNmYzQzNjc4OWFhNjZkNTlhMGU5M2YzMzdmN10gdWFwaTogQ29udmVy
dCBzb21lIHVzZXMgb2YgNiB0byBFVEhfQUxFTgpnaXQgYmlzZWN0IGdvb2QgZTIxNjk3NWFkOTdj
ZmNmYzQzNjc4OWFhNjZkNTlhMGU5M2YzMzdmNwojIGdvb2Q6IFtiYTUwODJjNzE0NzY4OTE2MjM3
NTc5NTZlYmZjMzYwNDBhYzMxN2UyXSBNZXJnZSBicmFuY2ggJ2V0aF9hbGVuJwpnaXQgYmlzZWN0
IGdvb2QgYmE1MDgyYzcxNDc2ODkxNjIzNzU3OTU2ZWJmYzM2MDQwYWMzMTdlMgojIGJhZDogWzBm
NzViMDljNzk4ZWQwMGMzMGQ3ZDU1NTFiODk2YmU4ODNiYzJhZWJdIGFmX3BhY2tldDogd2hlbiBz
ZW5kaW5nIGV0aGVybmV0IGZyYW1lcywgcGFyc2UgaGVhZGVyIGZvciBza2ItPnByb3RvY29sCmdp
dCBiaXNlY3QgYmFkIDBmNzViMDljNzk4ZWQwMGMzMGQ3ZDU1NTFiODk2YmU4ODNiYzJhZWIKIyBn
b29kOiBbZDI3ZmM3ODIwOGI1M2NjZGZkNmE1N2Q0YWM0NGE0NTljYTY2ODA2Zl0gc2N0cDogRG9u
J3QgbG9va3VwIGRzdCBpZiB0cmFuc3BvcnQgZHN0IGlzIHN0aWxsIHZhbGlkCmdpdCBiaXNlY3Qg
Z29vZCBkMjdmYzc4MjA4YjUzY2NkZmQ2YTU3ZDRhYzQ0YTQ1OWNhNjY4MDZmCiMgZmlyc3QgYmFk
IGNvbW1pdDogWzBmNzViMDljNzk4ZWQwMGMzMGQ3ZDU1NTFiODk2YmU4ODNiYzJhZWJdIGFmX3Bh
Y2tldDogd2hlbiBzZW5kaW5nIGV0aGVybmV0IGZyYW1lcywgcGFyc2UgaGVhZGVyIGZvciBza2It
PnByb3RvY29sCg==
--f46d043bdfde24120404e34c7c07
Content-Type: text/plain; charset=US-ASCII; name="git-bisect-visualize.txt"
Content-Disposition: attachment; filename="git-bisect-visualize.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hk1i8m021

Y29tbWl0IDBmNzViMDljNzk4ZWQwMGMzMGQ3ZDU1NTFiODk2YmU4ODNiYzJhZWIKQXV0aG9yOiBQ
aGlsIFN1dHRlciA8cGhpbEBud2wuY2M+CkRhdGU6ICAgRnJpIEF1ZyAyIDExOjM3OjM5IDIwMTMg
KzAyMDAKCiAgICBhZl9wYWNrZXQ6IHdoZW4gc2VuZGluZyBldGhlcm5ldCBmcmFtZXMsIHBhcnNl
IGhlYWRlciBmb3Igc2tiLT5wcm90b2NvbAogICAgCiAgICBUaGlzIG1heSBiZSBuZWNlc3Nhcnkg
d2hlbiB0aGUgU0tCIGlzIHBhc3NlZCB0byBvdGhlciBsYXllcnMgb24gdGhlIGdvLAogICAgd2hp
Y2ggY2hlY2sgdGhlIHByb3RvY29sIGZpZWxkIG9uIHRoZWlyIG93bi4gQW4gZXhhbXBsZSBpcyBh
IFZMQU4gcGFja2V0CiAgICBzZW50IG91dCB1c2luZyBBRl9QQUNLRVQgb24gYSBicmlkZ2UgaW50
ZXJmYWNlLiBUaGUgYnJpZGdpbmcgY29kZSBjaGVja3MKICAgIHRoZSBTS0Igc2l6ZSwgYWNjb3Vu
dGluZyBmb3IgYW55IFZMQU4gaGVhZGVyIG9ubHkgaWYgdGhlIHByb3RvY29sIGZpZWxkCiAgICBp
cyBzZXQgYWNjb3JkaW5nbHkuCiAgICAKICAgIE5vdGUgdGhhdCBldGhfdHlwZV90cmFucygpIHNl
dHMgc2tiLT5kZXYgdG8gdGhlIHBhc3NlZCBhcmd1bWVudCwgc28gdGhpcwogICAgY2FuIGJlIHNr
aXBwZWQgaW4gcGFja2V0X3NuZCgpIGZvciBldGhlcm5ldCBmcmFtZXMsIGFzIHdlbGwuCiAgICAK
ICAgIFNpZ25lZC1vZmYtYnk6IFBoaWwgU3V0dGVyIDxwaGlsQG53bC5jYz4KICAgIFNpZ25lZC1v
ZmYtYnk6IERhdmlkIFMuIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4K
--f46d043bdfde24120404e34c7c07--
