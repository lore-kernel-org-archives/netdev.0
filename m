From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Boot failure when using NFS on OMAP based evms
Date: Thu, 7 Apr 2016 11:52:40 -0400
Message-ID: <CAF=yD-JHbCOLOMZNwEjGwVosd8=zJ5DbdLP2dV_zWk7irQBN2w@mail.gmail.com>
References: <570597EA.3040902@ti.com> <CAF=yD-L=HZtD+LaKt1y4OcY0CQKOk_jmXZcQcyXjdfrPLpAhEQ@mail.gmail.com>
 <57067089.4080406@ti.com> <CA+FuTSeNJZPN70S_4UWt_68Wjo5Oks0swKRwVdwLLtYvgWDk+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Franklin S Cooper Jr." <fcooper@ti.com>,
	Sam Kumar <samanthakumar@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Tony Lindgren <tony@atomide.com>, mugunthanvnm@ti.com,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	nsekhar@ti.com, linux-omap@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+FuTSeNJZPN70S_4UWt_68Wjo5Oks0swKRwVdwLLtYvgWDk+A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> Currently linux-next is failing to boot via NFS on my AM335x GP evm,
>>>> AM437x GP evm and Beagle X15. I bisected the problem down to the commit
>>>> "udp: remove headers from UDP packets before queueing".
>>>
>>> Thanks for the report, and apologies for breaking your configuration.
>>> I had missed that sunrpc can dequeue skbs from a udp receive
>>> queue and makes assumptions about the layout of those packets. rxrpc
>>> does the same. From what I can tell so far, those are the only two
>>> protocols that do this. I have verified that the following fixes rxrpc for me
>>>
>>
>> Thank you for your quick response. I verified with all of the above
>> suggested changes that NFS works again on my 3 evms.
>
> Thanks a lot for testing, Franklin. I will send out the two patches.

Patches sent to netdev. I'll do another scan to verify that there are
no additional protocols that dequeue skbs from udp receive queues
and expect udp headers present.
