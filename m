From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH] net: core/dev: fix sparse warning
Date: Wed, 4 Feb 2015 12:50:53 +0000
Message-ID: <CA+V-a8vSfY79pqOoSr=F-Am8g4jmhM_DfC2f-SNaiNt9qu7hEA@mail.gmail.com>
References: <1423052746-3688-1-git-send-email-prabhakar.csengg@gmail.com> <1423053695.907.117.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423053695.907.117.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 4, 2015 at 12:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-02-04 at 12:25 +0000, Lad Prabhakar wrote:
>> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>>
>> this patch fixes following sparse warning:
>> net/core/dev.c: In function 'validate_xmit_skb_list':
>> net/core/dev.c:2720: warning: 'tail' may be used uninitialized in this function
>>
>> Although its a false positive, as head is assigned to NULL in the
>> beginning, due which later in the loop tail is assigned to skb->prev.
>>
>> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>> ---
>>  net/core/dev.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 8ce0d1a..c736467 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2717,7 +2717,7 @@ out_null:
>>
>>  struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev)
>>  {
>> -     struct sk_buff *next, *head = NULL, *tail;
>> +     struct sk_buff *next, *head = NULL, *tail = NULL;
>>
>>       for (; skb != NULL; skb = next) {
>>               next = skb->next;
>
> Which gcc/sparse versions are you using ?
>
I tried it on gcc 4.3.3 and sparse with 0.4.5-rc1 version.

Regards,
--Prabhakar Lad
