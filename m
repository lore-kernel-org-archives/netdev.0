From: Ye Xiaolong <xiaolong.ye@intel.com>
Subject: Re: [LKP] [net] 34fad54c25: kernel BUG at
 include/linux/skbuff.h:1935!
Date: Wed, 23 Nov 2016 16:55:28 +0800
Message-ID: <20161123085528.GB5438@yexl-desktop>
References: <582b7c30.nXQXP2V4/6pFiYwt%xiaolong.ye@intel.com>
 <CA+55aFxV7Bq583QOdYauuo2jY9EkAmgnceBukrN27ArjzFszYg@mail.gmail.com>
 <20161123064421.cewko2msg7mdawco@wfg-t540p.sh.intel.com>
 <CA+55aFx9q2xi1oi2j5QcYhMV490oj9CQ4N_OEXzC-3b6GeUQug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fengguang Wu <fengguang.wu@intel.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Willem de Bruijn <willemb@google.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, LKP <lkp@01.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFx9q2xi1oi2j5QcYhMV490oj9CQ4N_OEXzC-3b6GeUQug@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/22, Linus Torvalds wrote:
>On Tue, Nov 22, 2016 at 10:44 PM, Fengguang Wu <fengguang.wu@intel.com> wrote:
>>
>> On Tue, Nov 22, 2016 at 02:04:42PM -0800, Linus Torvalds wrote:
>>
>>> I also noticed that the kernel test robot had screwed up the
>>> participants list for some reason, and had
>>>
>>>  "Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>, David S.
>>> Miller" <davem@davemloft.net>
>>>
>>> as one of the participants. So there's some odd commit parsing issue
>>> there somewhere. But Alexander seems to have seen this report despite
>>> that, it just never went anywhere that I can tell.
>>
>>
>> Yeah the robot will CC all "Acked-by" people in the bug reports.
>>
>> Shall we limit it to the below TO/CC list?
>
>No. We do want to keep the Acked-by's on the cc.
>
>But you missed the real problem.
>
>It *didn't* cc the acked-by. Look closer. What happened was that it cc'd this:
>
> "Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>, David S. Miller"
>
> <davem@davemloft.net>
>

Seems that the robot failed to parse the commit log correctly due to
the "Reported-by: xxx" line missed '>' in the end, the robot got fooled
by it and generated wrong result, we'll try to improve it to handle this
kind of case.

    net: __skb_flow_dissect() must cap its return value
    
    After Tom patch, thoff field could point past the end of the buffer,
    this could fool some callers.
    
    If an skb was provided, skb->len should be the upper limit.
    If not, hlen is supposed to be the upper limit.
    
    Fixes: a6e544b0a88b ("flow_dissector: Jump to exit code in __skb_flow_dissect")
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Reported-by: Yibin Yang <yibyang@cisco.com
    Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
    Acked-by: Willem de Bruijn <willemb@google.com>
    Acked-by: Alexei Starovoitov <ast@kernel.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>


Thanks,
Xiaolong

>ie there is only _one_ email address (that of davem@davemloft.net),
>and the whole "Acked-by: Alexander Duyck <...>" part is quoted as the
>_name_ of that email address.
>
>At least that's what the headers look like for me in the original report:
>
>   From: kernel test robot <xiaolong.ye@intel.com>
>   To: Eric Dumazet <edumazet@google.com>
>   Cc: lkp@01.org, Linus Torvalds <torvalds@linux-foundation.org>,
>LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov
><ast@kernel.org>, Willem de Bruijn <willemb@google.com>, "Acked-by:
>Alexander Duyck <alexander.h.duyck@intel.com>, David S. Miller"
><davem@davemloft.net>
>
>Notice the quoting of that last "name".
>
>              Linus
