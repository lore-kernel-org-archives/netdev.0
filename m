From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: Re: [BUG] skb corruption and kernel panic at forwarding with fragmentation
Date: Thu, 7 Jan 2016 15:04:14 +0300
Message-ID: <CALYGNiOLhaY8mom01REK45O0fO=xLNgQUt4_tox9ymrqraNfAQ@mail.gmail.com>
References: <CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com>
	<CAM_iQpWsx6w2tFvSAy66M69FNi5iSp===EFCrO=4EPjy7y3iSg@mail.gmail.com>
	<CALYGNiOjeh4Jfvmc6fJHaZYJyinXmZjTHXcacNreBXvzB1ajtQ@mail.gmail.com>
	<20160106210532.GE27290@indiana.gru.redhat.com>
	<20160106220334.GA23789@breakpoint.cc>
	<20160106234943.GB23789@breakpoint.cc>
	<CALYGNiObS1fuDNi7Q69BwoWmU8xOnndzy7Z-m35aphjQWUuEnQ@mail.gmail.com>
	<CALYGNiN-cGxcEwiN-aPH7W1Pa7bLc2UY5LY98mXr+yZK+q5_BA@mail.gmail.com>
	<CANn89iLDRxh4x9hLyis2w7DfdA+0XZBhygN5gKFVA8nAgS-URQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iLDRxh4x9hLyis2w7DfdA+0XZBhygN5gKFVA8nAgS-URQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 7, 2016 at 2:59 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Thu, Jan 7, 2016 at 6:38 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>>
>> Also I've found strange thing: reason of expanding skb->cb from 40 to
>> 48 bypes in 2006
>> 3e3850e989c5d2eb1aab6f0fd9257759f0f4cbc6 was that struct inet6_skb_parm does
>> not fit. But it's is only 24 bytes. Does some arches add pad after
>> each _u16 field?
>
> "struct inet6_skb_parm" is part of struct tcp_skb_cb
>
> This is why Patrick had to increase skb->cb[]

Whoa. Funny. TCP moves that chunk back and forward instead of just
putting it at the first place in struct.
