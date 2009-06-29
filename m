From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root. Now=15
 size=11 bits
Date: Mon, 29 Jun 2009 11:51:52 +0200
Message-ID: <4A488EB8.4070602@itcare.pl>
References: <20090629083315.GA4712@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060103000105010700060307"
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:52992 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611AbZF2Jvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 05:51:52 -0400
In-Reply-To: <20090629083315.GA4712@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060103000105010700060307
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

I apply this patch

fib_triestats in attached file :)


Jarek Poplawski pisze:
> On 28-06-2009 23:36, Jarek Poplawski wrote:
>   
>> To David Miller:
>> since among patches tested negatively by Pawel are current 2 fixes
>> from 2.6.31-rc, I hope they weren't sent to -stable yet. Otherwise,
>> please withdraw them until they are tested alone. Thanks.
>>     
>
> David, IMHO this fix is needed in net-2.6 even if it doesn't fix the
> problem reported by Pawel (there could be still something more).
>
> Pawel, I see you decided to test my previous patch, but try to add
> this one on top.
>
> Thanks,
> Jarek P.
> ------------------->
> ipv4: Fix fib_trie rebalancing, part 3
>
> Alas current delaying of freeing old tnodes by RCU in trie_rebalance
> is still not enough because we can free a top tnode before updating a
> t->trie pointer.
>
> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>
>  net/ipv4/fib_trie.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 012cf5a..00a54b2 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1021,6 +1021,9 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
>  				      (struct node *)tn, wasfull);
>  
>  		tp = node_parent((struct node *) tn);
> +		if (!tp)
> +			rcu_assign_pointer(t->trie, (struct node *)tn);
> +
>  		tnode_free_flush();
>  		if (!tp)
>  			break;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   


--------------060103000105010700060307
Content-Type: text/plain;
 name="fib_triestats.txt"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="fib_triestats.txt"

Y2F0IC9wcm9jL25ldC9maWJfdHJpZXN0YXQNCkJhc2ljIGluZm86IHNpemUgb2YgbGVhZjog
MjAgYnl0ZXMsIHNpemUgb2YgdG5vZGU6IDM2IGJ5dGVzLg0KTWFpbjoNCiAgICAgICAgQXZl
ciBkZXB0aDogICAgIDIuMjkNCiAgICAgICAgTWF4IGRlcHRoOiAgICAgIDcNCiAgICAgICAg
TGVhdmVzOiAgICAgICAgIDI3NjkwOQ0KICAgICAgICBQcmVmaXhlczogICAgICAgMjkwMzgz
DQogICAgICAgIEludGVybmFsIG5vZGVzOiA2Njg5Mw0KICAgICAgICAgIDE6IDM0NzE1ICAy
OiAxNDAyNCAgMzogOTg4OSAgNDogNDgzMyAgNTogMjI3NSAgNjogMTE1MCAgNzogNSAgOTog
MSAgMTg6IDENCiAgICAgICAgUG9pbnRlcnM6IDY5MTY2Mg0KTnVsbCBwdHJzOiAzNDc4NjEN
ClRvdGFsIHNpemU6IDE4NDAzICBrQg0KDQpDb3VudGVyczoNCi0tLS0tLS0tLQ0KZ2V0cyA9
IDIyOTc1NzkNCmJhY2t0cmFja3MgPSAxMzE0OTENCnNlbWFudGljIG1hdGNoIHBhc3NlZCA9
IDIyMzMwNzANCnNlbWFudGljIG1hdGNoIG1pc3MgPSA0Mg0KbnVsbCBub2RlIGhpdD0gMjAx
Njg4Mw0Kc2tpcHBlZCBub2RlIHJlc2l6ZSA9IDANCg0KTG9jYWw6DQogICAgICAgIEF2ZXIg
ZGVwdGg6ICAgICAzLjc1DQogICAgICAgIE1heCBkZXB0aDogICAgICA1DQogICAgICAgIExl
YXZlczogICAgICAgICAxMg0KICAgICAgICBQcmVmaXhlczogICAgICAgMTMNCiAgICAgICAg
SW50ZXJuYWwgbm9kZXM6IDEwDQogICAgICAgICAgMTogOSAgMjogMQ0KICAgICAgICBQb2lu
dGVyczogMjINCk51bGwgcHRyczogMQ0KVG90YWwgc2l6ZTogMiAga0INCg0KQ291bnRlcnM6
DQotLS0tLS0tLS0NCmdldHMgPSAyMzAyMTAyDQpiYWNrdHJhY2tzID0gMTU0NTE5Nw0Kc2Vt
YW50aWMgbWF0Y2ggcGFzc2VkID0gNDUzNg0Kc2VtYW50aWMgbWF0Y2ggbWlzcyA9IDANCm51
bGwgbm9kZSBoaXQ9IDE5MjY2NA0Kc2tpcHBlZCBub2RlIHJlc2l6ZSA9IDANCg0KLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLQ0KDQpjYXQgL3Byb2MvbmV0L2ZpYl90cmllc3RhdA0KQmFzaWMgaW5mbzogc2l6ZSBv
ZiBsZWFmOiAyMCBieXRlcywgc2l6ZSBvZiB0bm9kZTogMzYgYnl0ZXMuDQpNYWluOg0KICAg
ICAgICBBdmVyIGRlcHRoOiAgICAgMi4yOQ0KICAgICAgICBNYXggZGVwdGg6ICAgICAgNw0K
ICAgICAgICBMZWF2ZXM6ICAgICAgICAgMjc2OTA0DQogICAgICAgIFByZWZpeGVzOiAgICAg
ICAyOTAzNzgNCiAgICAgICAgSW50ZXJuYWwgbm9kZXM6IDY2ODg5DQogICAgICAgICAgMTog
MzQ3MTEgIDI6IDE0MDIzICAzOiA5ODkwICA0OiA0ODMzICA1OiAyMjc1ICA2OiAxMTUwICA3
OiA1ICA5OiAxICAxODogMQ0KICAgICAgICBQb2ludGVyczogNjkxNjU4DQpOdWxsIHB0cnM6
IDM0Nzg2Ng0KVG90YWwgc2l6ZTogMTg0MDIgIGtCDQoNCkNvdW50ZXJzOg0KLS0tLS0tLS0t
DQpnZXRzID0gMzAwNjk0NQ0KYmFja3RyYWNrcyA9IDEzODc4Nw0Kc2VtYW50aWMgbWF0Y2gg
cGFzc2VkID0gMjk0MjA0Nw0Kc2VtYW50aWMgbWF0Y2ggbWlzcyA9IDg1DQpudWxsIG5vZGUg
aGl0PSAyODI2Mzc3DQpza2lwcGVkIG5vZGUgcmVzaXplID0gMA0KDQpMb2NhbDoNCiAgICAg
ICAgQXZlciBkZXB0aDogICAgIDMuNzUNCiAgICAgICAgTWF4IGRlcHRoOiAgICAgIDUNCiAg
ICAgICAgTGVhdmVzOiAgICAgICAgIDEyDQogICAgICAgIFByZWZpeGVzOiAgICAgICAxMw0K
ICAgICAgICBJbnRlcm5hbCBub2RlczogMTANCiAgICAgICAgICAxOiA5ICAyOiAxDQogICAg
ICAgIFBvaW50ZXJzOiAyMg0KTnVsbCBwdHJzOiAxDQpUb3RhbCBzaXplOiAyICBrQg0KDQpD
b3VudGVyczoNCi0tLS0tLS0tLQ0KZ2V0cyA9IDMwMTE1MDQNCmJhY2t0cmFja3MgPSAxNzk2
NTg3DQpzZW1hbnRpYyBtYXRjaCBwYXNzZWQgPSA0NTc3DQpzZW1hbnRpYyBtYXRjaCBtaXNz
ID0gMA0KbnVsbCBub2RlIGhpdD0gMTkyNzQ3DQpza2lwcGVkIG5vZGUgcmVzaXplID0gMA0K
DQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLQ0KDQpjYXQgL3Byb2MvbmV0L2ZpYl90cmllc3RhdA0KQmFzaWMgaW5mbzog
c2l6ZSBvZiBsZWFmOiAyMCBieXRlcywgc2l6ZSBvZiB0bm9kZTogMzYgYnl0ZXMuDQpNYWlu
Og0KICAgICAgICBBdmVyIGRlcHRoOiAgICAgMi4yOQ0KICAgICAgICBNYXggZGVwdGg6ICAg
ICAgNw0KICAgICAgICBMZWF2ZXM6ICAgICAgICAgMjc2OTA0DQogICAgICAgIFByZWZpeGVz
OiAgICAgICAyOTAzNzgNCiAgICAgICAgSW50ZXJuYWwgbm9kZXM6IDY2ODkxDQogICAgICAg
ICAgMTogMzQ3MTAgIDI6IDE0MDI1ICAzOiA5ODkyICA0OiA0ODMyICA1OiAyMjc1ICA2OiAx
MTUwICA3OiA1ICA5OiAxICAxODogMQ0KICAgICAgICBQb2ludGVyczogNjkxNjY0DQpOdWxs
IHB0cnM6IDM0Nzg3MA0KVG90YWwgc2l6ZTogMTg0MDIgIGtCDQoNCkNvdW50ZXJzOg0KLS0t
LS0tLS0tDQpnZXRzID0gMzMyMDYzMw0KYmFja3RyYWNrcyA9IDE0MTkwNA0Kc2VtYW50aWMg
bWF0Y2ggcGFzc2VkID0gMzI1NTU4NQ0Kc2VtYW50aWMgbWF0Y2ggbWlzcyA9IDk5DQpudWxs
IG5vZGUgaGl0PSAzMTc3NTQzDQpza2lwcGVkIG5vZGUgcmVzaXplID0gMA0KDQpMb2NhbDoN
CiAgICAgICAgQXZlciBkZXB0aDogICAgIDMuNzUNCiAgICAgICAgTWF4IGRlcHRoOiAgICAg
IDUNCiAgICAgICAgTGVhdmVzOiAgICAgICAgIDEyDQogICAgICAgIFByZWZpeGVzOiAgICAg
ICAxMw0KICAgICAgICBJbnRlcm5hbCBub2RlczogMTANCiAgICAgICAgICAxOiA5ICAyOiAx
DQogICAgICAgIFBvaW50ZXJzOiAyMg0KTnVsbCBwdHJzOiAxDQpUb3RhbCBzaXplOiAyICBr
Qg0KDQpDb3VudGVyczoNCi0tLS0tLS0tLQ0KZ2V0cyA9IDMzMjUyMjYNCmJhY2t0cmFja3Mg
PSAxOTA0MDIyDQpzZW1hbnRpYyBtYXRjaCBwYXNzZWQgPSA0NjAxDQpzZW1hbnRpYyBtYXRj
aCBtaXNzID0gMA0KbnVsbCBub2RlIGhpdD0gMTkyNzgyDQpza2lwcGVkIG5vZGUgcmVzaXpl
ID0gMA0KDQo=
--------------060103000105010700060307--
