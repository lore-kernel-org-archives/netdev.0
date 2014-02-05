From: David Miller <davem@davemloft.net>
Subject: Re: [bisected] Re: WARNING: at net/ipv4/devinet.c:1599
Date: Tue, 04 Feb 2014 20:41:24 -0800 (PST)
Message-ID: <20140204.204124.155963712324513810.davem@davemloft.net>
References: <CAHA+R7Omv++NCg=nocVsW+tM=Zv_qCNhX1JjtFTuCzfz9B3Cig@mail.gmail.com>
	<CAMuHMdWUR-x=fwG26xg8AsUQwL+FXLaQAnkaWHbrVaep0QzHJQ@mail.gmail.com>
	<CAMuHMdWrYj1te-7qhKg-uHmXpuLaBBdqCEmpv_fgYSmaN3yujw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWrYj1te-7qhKg-uHmXpuLaBBdqCEmpv_fgYSmaN3yujw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 4 Feb 2014 21:03:24 +0100

> On Tue, Feb 4, 2014 at 8:20 PM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>> On Tue, Feb 4, 2014 at 7:08 PM, Cong Wang <cwang@twopensource.com> wrote:
>>> On Tue, Feb 4, 2014 at 6:19 AM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>>>>
>>>> Anyone with a clue?
>>>>
>>>
>>> Looks like we need:
>>>
>>> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>>> index ac2dff3..bdbf68b 100644
>>> --- a/net/ipv4/devinet.c
>>> +++ b/net/ipv4/devinet.c
>>> @@ -1443,7 +1443,8 @@ static size_t inet_nlmsg_size(void)
>>>                + nla_total_size(4) /* IFA_LOCAL */
>>>                + nla_total_size(4) /* IFA_BROADCAST */
>>>                + nla_total_size(IFNAMSIZ) /* IFA_LABEL */
>>> -              + nla_total_size(4);  /* IFA_FLAGS */
>>> +              + nla_total_size(4)  /* IFA_FLAGS */
>>> +              + nla_total_size(sizeof(struct ifa_cacheinfo)); /*
>>> IFA_CACHEINFO */
>>>  }
>>
>> Thanks for your suggestion, but it doesn't help :-(
> 
> Bummer, I applied it to the wrong tree.
> 
> Yes, it works, thanks a lot!
> 
> David, Jiri, is this the right fix, or just a band-aid?

It looks correct, and if you look ipv6 does this correctly already,
someone please submit this formally.
