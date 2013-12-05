From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH] x25: convert printks to pr_<level>
Date: Thu, 5 Dec 2013 14:16:41 +0800
Message-ID: <52A01A49.7020504@huawei.com>
References: <529FEDBC.9030302@huawei.com> <52A01361.1060501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-x25@vger.kernel.org>, <netdev@vger.kernel.org>
To: Yi Li <lovelylich@gmail.com>, David Miller <davem@davemloft.net>,
	<andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:47859 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313Ab3LEGRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 01:17:34 -0500
In-Reply-To: <52A01361.1060501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/5 13:47, Yi Li wrote:
>=20
> =E4=BA=8E 2013=E5=B9=B412=E6=9C=8805=E6=97=A5 11:06, Wang Weidong =E5=
=86=99=E9=81=93:
>> use pr_<level> instead of printk(LEVEL)
>>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>   net/x25/af_x25.c         |  2 +-
>>   net/x25/x25_dev.c        |  8 ++++----
>>   net/x25/x25_facilities.c | 12 ++++++------
>>   net/x25/x25_forward.c    |  2 +-
>>   net/x25/x25_in.c         |  2 +-
>>   net/x25/x25_link.c       |  4 ++--
>>   net/x25/x25_subr.c       |  4 ++--
>>   7 files changed, 17 insertions(+), 17 deletions(-)
>>
>> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
>> index 7622789..5142a40 100644
>> --- a/net/x25/af_x25.c
>> +++ b/net/x25/af_x25.c
>> @@ -1809,7 +1809,7 @@ static int __init x25_init(void)
>>       if (rc !=3D 0)
>>           goto out_sock;
>>   -    printk(KERN_INFO "X.25 for Linux Version 0.2\n");
>> +    pr_info("X.25 for Linux Version 0.2\n");
>>         x25_register_sysctl();
>>       rc =3D x25_proc_init();
>> diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
>> index a8a2363..ccf8fd9 100644
>> --- a/net/x25/x25_dev.c
>> +++ b/net/x25/x25_dev.c
>> @@ -89,7 +89,7 @@ static int x25_receive_data(struct sk_buff *skb, s=
truct x25_neigh *nb)
>>   */
>>         if (frametype !=3D X25_CLEAR_CONFIRMATION)
>> -        printk(KERN_DEBUG "x25_receive_data(): unknown frame type %=
2x\n",frametype);
>> +        pr_debug("x25_receive_data(): unknown frame type %2x\n",fra=
metype);
>>         return 0;
>>   }
>> @@ -114,7 +114,7 @@ int x25_lapb_receive_frame(struct sk_buff *skb, =
struct net_device *dev,
>>        */
>>       nb =3D x25_get_neigh(dev);
>>       if (!nb) {
>> -        printk(KERN_DEBUG "X.25: unknown neighbour - %s\n", dev->na=
me);
>> +        pr_debug("X.25: unknown neighbour - %s\n", dev->name);
>>           goto drop;
>>       }
>>   @@ -154,7 +154,7 @@ void x25_establish_link(struct x25_neigh *nb)
>>       switch (nb->dev->type) {
>>       case ARPHRD_X25:
>>           if ((skb =3D alloc_skb(1, GFP_ATOMIC)) =3D=3D NULL) {
>> -            printk(KERN_ERR "x25_dev: out of memory\n");
>> +            pr_err("x25_dev: out of memory\n");
>>               return;
>>           }
>>           ptr  =3D skb_put(skb, 1);
>> @@ -189,7 +189,7 @@ void x25_terminate_link(struct x25_neigh *nb)
>>         skb =3D alloc_skb(1, GFP_ATOMIC);
>>       if (!skb) {
>> -        printk(KERN_ERR "x25_dev: out of memory\n");
>> +        pr_err("x25_dev: out of memory\n");
>>           return;
>>       }
>>   diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
>> index b825325..a4c2a2a 100644
>> --- a/net/x25/x25_facilities.c
>> +++ b/net/x25/x25_facilities.c
>> @@ -109,7 +109,7 @@ int x25_parse_facilities(struct sk_buff *skb, st=
ruct x25_facilities *facilities,
>>               case X25_MARKER:
>>                   break;
>>               default:
>> -                printk(KERN_DEBUG "X.25: unknown facility "
>> +                pr_debug("X.25: unknown facility "
>>                          "%02X, value %02X\n",
>>                          p[0], p[1]);
>>                   break;
>> @@ -132,7 +132,7 @@ int x25_parse_facilities(struct sk_buff *skb, st=
ruct x25_facilities *facilities,
>>                   *vc_fac_mask |=3D X25_MASK_WINDOW_SIZE;
>>                   break;
>>               default:
>> -                printk(KERN_DEBUG "X.25: unknown facility "
>> +                pr_debug("X.25: unknown facility "
>>                          "%02X, values %02X, %02X\n",
>>                          p[0], p[1], p[2]);
>>                   break;
>> @@ -143,7 +143,7 @@ int x25_parse_facilities(struct sk_buff *skb, st=
ruct x25_facilities *facilities,
>>           case X25_FAC_CLASS_C:
>>               if (len < 4)
>>                   return -1;
>> -            printk(KERN_DEBUG "X.25: unknown facility %02X, "
>> +            pr_debug("X.25: unknown facility %02X, "
>>                      "values %02X, %02X, %02X\n",
>>                      p[0], p[1], p[2], p[3]);
>>               p   +=3D 4;
>> @@ -172,7 +172,7 @@ int x25_parse_facilities(struct sk_buff *skb, st=
ruct x25_facilities *facilities,
>>                   *vc_fac_mask |=3D X25_MASK_CALLED_AE;
>>                   break;
>>               default:
>> -                printk(KERN_DEBUG "X.25: unknown facility %02X,"
>> +                pr_debug("X.25: unknown facility %02X,"
>>                       "length %d\n", p[0], p[1]);
>>                   break;
>>               }
>> @@ -341,12 +341,12 @@ void x25_limit_facilities(struct x25_facilitie=
s *facilities,
>>         if (!nb->extended) {
>>           if (facilities->winsize_in  > 7) {
>> -            printk(KERN_DEBUG "X.25: incoming winsize limited to 7\=
n");
>> +            pr_debug("X.25: incoming winsize limited to 7\n");
>>               facilities->winsize_in =3D 7;
>>           }
>>           if (facilities->winsize_out > 7) {
>>               facilities->winsize_out =3D 7;
>> -            printk( KERN_DEBUG "X.25: outgoing winsize limited to 7=
\n");
>> +            pr_debug("X.25: outgoing winsize limited to 7\n");
>>           }
>>       }
>>   }
>> diff --git a/net/x25/x25_forward.c b/net/x25/x25_forward.c
>> index c541b62..a8b0778 100644
>> --- a/net/x25/x25_forward.c
>> +++ b/net/x25/x25_forward.c
>> @@ -51,7 +51,7 @@ int x25_forward_call(struct x25_address *dest_addr=
, struct x25_neigh *from,
>>       list_for_each(entry, &x25_forward_list) {
>>           x25_frwd =3D list_entry(entry, struct x25_forward, node);
>>           if (x25_frwd->lci =3D=3D lci) {
>> -            printk(KERN_WARNING "X.25: call request for lci which i=
s already registered!, transmitting but not registering new pair\n");
>> +            pr_warn("X.25: call request for lci which is already re=
gistered!, transmitting but not registering new pair\n");
>>               same_lci =3D 1;
>>           }
>>       }
>> diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
>> index a49cd4e..20e850e 100644
>> --- a/net/x25/x25_in.c
>> +++ b/net/x25/x25_in.c
>> @@ -317,7 +317,7 @@ static int x25_state3_machine(struct sock *sk, s=
truct sk_buff *skb, int frametyp
>>               break;
>>             default:
>> -            printk(KERN_WARNING "x25: unknown %02X in state 3\n", f=
rametype);
>> +            pr_warn("x25: unknown %02X in state 3\n", frametype);
>>               break;
>>       }
>>   diff --git a/net/x25/x25_link.c b/net/x25/x25_link.c
>> index 4acacf3..b5f44d3 100644
>> --- a/net/x25/x25_link.c
>> +++ b/net/x25/x25_link.c
>> @@ -93,13 +93,13 @@ void x25_link_control(struct sk_buff *skb, struc=
t x25_neigh *nb,
>>           if (!pskb_may_pull(skb, X25_STD_MIN_LEN + 4))
>>               break;
>>   -        printk(KERN_WARNING "x25: diagnostic #%d - %02X %02X %02X=
\n",
>> +        pr_warn("x25: diagnostic #%d - %02X %02X %02X\n",
>>                  skb->data[3], skb->data[4],
>>                  skb->data[5], skb->data[6]);
>>           break;
>>         default:
>> -        printk(KERN_WARNING "x25: received unknown %02X with LCI 00=
0\n",
>> +        pr_warn("x25: received unknown %02X with LCI 000\n",
>>                  frametype);
>>           break;
>>       }
>> diff --git a/net/x25/x25_subr.c b/net/x25/x25_subr.c
>> index 5170d52..5e6d96b 100644
>> --- a/net/x25/x25_subr.c
>> +++ b/net/x25/x25_subr.c
>> @@ -148,7 +148,7 @@ void x25_write_internal(struct sock *sk, int fra=
metype)
>>       case X25_RESET_CONFIRMATION:
>>           break;
>>       default:
>> -        printk(KERN_ERR "X.25: invalid frame type %02X\n", frametyp=
e);
>> +        pr_err("X.25: invalid frame type %02X\n", frametype);
>>           return;
>>       }
>>   @@ -338,7 +338,7 @@ int x25_decode(struct sock *sk, struct sk_buff=
 *skb, int *ns, int *nr, int *q,
>>           }
>>       }
>>   -    printk(KERN_DEBUG "X.25: invalid PLP frame %02X %02X %02X\n",
>> +    pr_debug("X.25: invalid PLP frame %02X %02X %02X\n",
>>              frame[0], frame[1], frame[2]);
>>         return X25_ILLEGAL;
> I just wonder why we need to change? What's your reason and isn't OK =
for now?
>=20

Yes, it is OK for now.
I think the use of pr_<level> is preferred to printk, although it just =
a=20
macro replace.

>=20
>=20
> regards,
> Yi
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> .
>=20
