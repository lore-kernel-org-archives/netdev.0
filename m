From: Minho Ban <mhban@samsung.com>
Subject: Re: [RFC/PATCH] Bluetooth: prevent double l2cap_chan_destroy
Date: Wed, 23 May 2012 10:39:34 +0900
Message-ID: <4FBC3FD6.6050704@samsung.com>
References: <4FB992C8.8090105@samsung.com> <20120521162137.GE16942@joana>
 <4FBAFEF5.2000207@samsung.com> <4FBB8544.3040408@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gustavo Padovan <gustavo@padovan.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chanyeol Park <chanyeol.park@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:63494 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760399Ab2EWBjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 21:39:36 -0400
In-reply-to: <4FBB8544.3040408@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2012 09:23 PM, Chanyeol Park wrote:
> Hi
>=20
> On 2012=EB=85=84 05=EC=9B=94 22=EC=9D=BC 11:50, Minho Ban wrote:
>> @@ -1343,10 +1343,10 @@ static void l2cap_conn_del(struct hci_conn *=
hcon, int err)
>>                  l2cap_chan_lock(chan);
>>
>>                  l2cap_chan_del(chan, err);
>> +               chan->ops->close(chan->data);
>>
>>                  l2cap_chan_unlock(chan);
>>
>> -               chan->ops->close(chan->data);
>>                  l2cap_chan_put(chan);
>>          }
> I think this patch does not make sense Because inside chan->ops->clos=
e() "chan" could be freed in the l2cap_chan_destroy().
>=20

I agree, thanks for pointing out.
