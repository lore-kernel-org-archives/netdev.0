From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [bisected] Re: WARNING: at net/ipv4/devinet.c:1599
Date: Tue, 4 Feb 2014 21:03:24 +0100
Message-ID: <CAMuHMdWrYj1te-7qhKg-uHmXpuLaBBdqCEmpv_fgYSmaN3yujw@mail.gmail.com>
References: <CAMuHMdVCeFek2LX0_AnA8zg_yYhXvzw19rH8OsqbWWb-rb9w-A@mail.gmail.com>
	<CAHA+R7Omv++NCg=nocVsW+tM=Zv_qCNhX1JjtFTuCzfz9B3Cig@mail.gmail.com>
	<CAMuHMdWUR-x=fwG26xg8AsUQwL+FXLaQAnkaWHbrVaep0QzHJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWUR-x=fwG26xg8AsUQwL+FXLaQAnkaWHbrVaep0QzHJQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 4, 2014 at 8:20 PM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> On Tue, Feb 4, 2014 at 7:08 PM, Cong Wang <cwang@twopensource.com> wrote:
>> On Tue, Feb 4, 2014 at 6:19 AM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>>>
>>> Anyone with a clue?
>>>
>>
>> Looks like we need:
>>
>> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>> index ac2dff3..bdbf68b 100644
>> --- a/net/ipv4/devinet.c
>> +++ b/net/ipv4/devinet.c
>> @@ -1443,7 +1443,8 @@ static size_t inet_nlmsg_size(void)
>>                + nla_total_size(4) /* IFA_LOCAL */
>>                + nla_total_size(4) /* IFA_BROADCAST */
>>                + nla_total_size(IFNAMSIZ) /* IFA_LABEL */
>> -              + nla_total_size(4);  /* IFA_FLAGS */
>> +              + nla_total_size(4)  /* IFA_FLAGS */
>> +              + nla_total_size(sizeof(struct ifa_cacheinfo)); /*
>> IFA_CACHEINFO */
>>  }
>
> Thanks for your suggestion, but it doesn't help :-(

Bummer, I applied it to the wrong tree.

Yes, it works, thanks a lot!

David, Jiri, is this the right fix, or just a band-aid?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
