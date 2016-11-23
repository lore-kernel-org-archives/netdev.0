From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [LKP] [net] 34fad54c25: kernel BUG at include/linux/skbuff.h:1935!
Date: Tue, 22 Nov 2016 23:07:16 -0800
Message-ID: <CA+55aFx9q2xi1oi2j5QcYhMV490oj9CQ4N_OEXzC-3b6GeUQug@mail.gmail.com>
References: <582b7c30.nXQXP2V4/6pFiYwt%xiaolong.ye@intel.com>
 <CA+55aFxV7Bq583QOdYauuo2jY9EkAmgnceBukrN27ArjzFszYg@mail.gmail.com> <20161123064421.cewko2msg7mdawco@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kernel test robot <xiaolong.ye@intel.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Willem de Bruijn <willemb@google.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, LKP <lkp@01.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161123064421.cewko2msg7mdawco@wfg-t540p.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2016 at 10:44 PM, Fengguang Wu <fengguang.wu@intel.com> wrote:
>
> On Tue, Nov 22, 2016 at 02:04:42PM -0800, Linus Torvalds wrote:
>
>> I also noticed that the kernel test robot had screwed up the
>> participants list for some reason, and had
>>
>>  "Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>, David S.
>> Miller" <davem@davemloft.net>
>>
>> as one of the participants. So there's some odd commit parsing issue
>> there somewhere. But Alexander seems to have seen this report despite
>> that, it just never went anywhere that I can tell.
>
>
> Yeah the robot will CC all "Acked-by" people in the bug reports.
>
> Shall we limit it to the below TO/CC list?

No. We do want to keep the Acked-by's on the cc.

But you missed the real problem.

It *didn't* cc the acked-by. Look closer. What happened was that it cc'd this:

 "Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>, David S. Miller"

 <davem@davemloft.net>

ie there is only _one_ email address (that of davem@davemloft.net),
and the whole "Acked-by: Alexander Duyck <...>" part is quoted as the
_name_ of that email address.

At least that's what the headers look like for me in the original report:

   From: kernel test robot <xiaolong.ye@intel.com>
   To: Eric Dumazet <edumazet@google.com>
   Cc: lkp@01.org, Linus Torvalds <torvalds@linux-foundation.org>,
LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov
<ast@kernel.org>, Willem de Bruijn <willemb@google.com>, "Acked-by:
Alexander Duyck <alexander.h.duyck@intel.com>, David S. Miller"
<davem@davemloft.net>

Notice the quoting of that last "name".

              Linus
