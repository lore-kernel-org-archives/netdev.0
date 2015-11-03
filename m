From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH v2 net-next] net/core: generic support for disabling netdev
 features down stack
Date: Tue, 03 Nov 2015 08:57:02 -0500
Message-ID: <5638BD2E.8010508@redhat.com>
References: <1446486818-26166-1-git-send-email-jarod@redhat.com> <1446519359-21400-1-git-send-email-jarod@redhat.com> <5638865D.2000804@cumulusnetworks.com> <CAMuHMdXrs2fkHw+DGgutM1y71Y=MTsxSqJ+J78e_Q7oZjaNesA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXrs2fkHw+DGgutM1y71Y=MTsxSqJ+J78e_Q7oZjaNesA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven wrote:
> On Tue, Nov 3, 2015 at 11:03 AM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com>  wrote:
>> On 11/03/2015 03:55 AM, Jarod Wilson wrote:
>> [snip]
>>> +#define for_each_netdev_feature(mask_addr, feature)                          \
>>> +     int bit;                                                                \
>>> +     for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT) \
>>> +             feature = __NETIF_F_BIT(bit);
>>> +
>> ^
>> This is broken, it will not work for more than a single feature.
>
> Indeed it is.
>
> This is used as:
>
>          for_each_netdev_feature(&upper_disables, feature) {
>          ...
>          }
>
> which expands to:
>
>          int bit;
>          for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
>                  feature = __NETIF_F_BIT(bit);
>          {
>                  ...
>          }
>
> Note the assignment to "feature" happens outside the {}-delimited block.
> And the block is always executed once.

Bah, crap, I was still staring at the code not seeing it, thank you for 
the detailed cluebat. I'll fix that up right now.

-- 
Jarod Wilson
jarod@redhat.com
