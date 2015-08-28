From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [Bridge] [PATCH net-next] bridge: Add netlink support for vlan_protocol
 attribute
Date: Fri, 28 Aug 2015 20:06:17 +0900
Message-ID: <55E040A9.8040707@gmail.com>
References: <1440655205-14247-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <63AC6A69-F9A1-4A83-8EF7-D897243743B4@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S . Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34616 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737AbbH1LGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 07:06:23 -0400
Received: by pabzx8 with SMTP id zx8so59834169pab.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 04:06:23 -0700 (PDT)
In-Reply-To: <63AC6A69-F9A1-4A83-8EF7-D897243743B4@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/08/28 (=E9=87=91) 0:48, Nikolay Aleksandrov wrote:
>
>> On Aug 26, 2015, at 11:00 PM, Toshiaki Makita <makita.toshiaki@lab.n=
tt.co.jp> wrote:
>>
>> This enables bridge vlan_protocol to be configured through netlink.
>>
>> When CONFIG_BRIDGE_VLAN_FILTERING is disabled, kernel behaves the
>> same way as this feature is not implemented.
>>
>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> ---
>> include/uapi/linux/if_link.h |  1 +
>> net/bridge/br_netlink.c      | 34 ++++++++++++++++++++++++++++++++++
>> net/bridge/br_private.h      |  1 +
>> net/bridge/br_vlan.c         | 35 +++++++++++++++++++++-------------=
-
>> 4 files changed, 57 insertions(+), 14 deletions(-)
>>
>
> Nice, looks good. I have a similar patch as well and was going to ask=
 wouldn=E2=80=99t it be
> better to make empty stubs which return an error when vlan filtering =
isn=E2=80=99t configured
> and drop the ifdefs in the netlink handling code ?
> Similar to how vlan_filtering netlink attribute is handled in commit:
> a7854037da00 ("bridge: netlink: add support for vlan_filtering attrib=
ute=E2=80=9D)
>
> Potential problem would be the return of the protocol, but I think if=
 0 is returned that
> can be handled.

This is the exact reason why I didn't implement the stub.
I wanted to avoid to charge userspace with that special casing 0.
Also, this is consistent with sysfs implementation, which doesn't expos=
e=20
vlan_* entries when CONFIG_BRIDGE_VLAN_PROTOCOL is disabled.

Toshiaki Makita
