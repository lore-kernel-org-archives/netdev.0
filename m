From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-4.6/net/kcm/kcmsock.c:1508: bad if test ?
Date: Tue, 17 May 2016 09:49:32 -0700
Message-ID: <CAM_iQpUYa8brHBf-aFLzgF6duBEnvAzejJ=i1Of0RsNDDhKMxQ@mail.gmail.com>
References: <CAMzoambRTmpCmM0upiM5PMZtEioSMpw3QB4k--OCvHKmhCnw7w@mail.gmail.com>
 <CAM_iQpWi4L-Dz92ce_nfvXJujEDKnmy_d6Ytsd0hLokvsSV3eA@mail.gmail.com> <20160517.124413.1000589286930755736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Binderman <linuxdev.baldrick@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, dcb314@hotmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160517.124413.1000589286930755736.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2016 at 9:44 AM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 17 May 2016 09:04:21 -0700
>
>> On Mon, May 16, 2016 at 11:40 AM, David Binderman
>> <linuxdev.baldrick@gmail.com> wrote:
>>> Hello there,
>>>
>>> linux-4.6/net/kcm/kcmsock.c:1508]: (style) Checking if unsigned
>>> variable 'copied' is less than zero.
>>>
>>> Source code is
>>>
>>>     if (copied < 0) {
>>>
>>> but
>>>
>>>    size_t copied;
>>>
>>> Suggest code rework.
>>
>> Thanks for the report! I think the following patch is enough:
>>
>> diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
>> index 40662d73..8bfc390 100644
>> --- a/net/kcm/kcmsock.c
>> +++ b/net/kcm/kcmsock.c
>> @@ -1483,7 +1483,7 @@ static ssize_t kcm_splice_read(struct socket
>> *sock, loff_t *ppos,
>>         long timeo;
>>         struct kcm_rx_msg *rxm;
>>         int err = 0;
>> -       size_t copied;
>> +       int copied;
>
> Or 'ssize_t' since that is the return type of this function.

skb_splice_bits() is still declared as int:

int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int
offset,
...

But yeah, we could change it to ssize_t as well, perhaps in a
separated patch?
