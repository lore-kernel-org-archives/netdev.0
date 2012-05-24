From: Minho Ban <mhban@samsung.com>
Subject: Re: [PATCH] Bluetooth: Fix null pointer dereference in l2cap_chan_send
Date: Thu, 24 May 2012 15:32:41 +0900
Message-ID: <4FBDD609.8060702@samsung.com>
References: <4FB9932B.9070101@samsung.com> <4FBB8828.303@samsung.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <4FBB8828.303@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2012 09:35 PM, Chanyeol Park wrote:
> Hi
> On 2012=EB=85=84 05=EC=9B=94 21=EC=9D=BC 09:58, Minho Ban wrote:
>> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
>> index 3bb1611..98d4541 100644
>> --- a/net/bluetooth/l2cap_sock.c
>> +++ b/net/bluetooth/l2cap_sock.c
>> @@ -727,10 +727,12 @@ static int l2cap_sock_sendmsg(struct kiocb *io=
cb, struct socket *sock, struct ms
>>       if (msg->msg_flags&  MSG_OOB)
>>           return -EOPNOTSUPP;
>>
>> -    if (sk->sk_state !=3D BT_CONNECTED)
>> +    l2cap_chan_lock(chan);
>> +    if (sk->sk_state !=3D BT_CONNECTED || !chan->conn) {
>> +        l2cap_chan_unlock(chan);
>>           return -ENOTCONN;
>> +    }
>>
>> -    l2cap_chan_lock(chan);
>>       err =3D l2cap_chan_send(chan, msg, len, sk->sk_priority);
>>       l2cap_chan_unlock(chan);
>>  =20
> Beside !chan->conn condition,I think it makes sense that sk_state che=
ck should be moved after l2cap_chan_lock()
> because sk_state could be changed due to l2cap_conn_del().
>=20

Thanks, chan->conn condition is not necessary, move sk->sk_state !=3D B=
T_CONNECTED behind chan_lock is enough.
I'll amend this patch.

Regards
Minho Ban
