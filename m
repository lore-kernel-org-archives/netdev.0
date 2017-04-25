From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/packet: initialize val in packet_getsockopt()
Date: Tue, 25 Apr 2017 12:32:01 -0400 (EDT)
Message-ID: <20170425.123201.1910437101082999848.davem@davemloft.net>
References: <20170424125914.43270-1-glider@google.com>
        <20170425.114433.143144279134920277.davem@davemloft.net>
        <CAG_fn=URNuXxc7wEaXd_p7B46RRCYYMTv5rOVc_U1CdvervzPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG_fn=URNuXxc7wEaXd_p7B46RRCYYMTv5rOVc_U1CdvervzPQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Tue, 25 Apr 2017 18:27:04 +0200

> On Tue, Apr 25, 2017 at 5:44 PM, David Miller <davem@davemloft.net> wrote:
>> From: Alexander Potapenko <glider@google.com>
>> Date: Mon, 24 Apr 2017 14:59:14 +0200
>>
>>> In the case getsockopt() is called with PACKET_HDRLEN and optlen < 4
>>> |val| remains uninitialized and the syscall may behave differently
>>> depending on its value. This doesn't have security consequences (as the
>>> uninit bytes aren't copied back), but it's still cleaner to initialize
>>> |val| and ensure optlen is not less than sizeof(int).
>>>
>>> This bug has been detected with KMSAN.
>>>
>>> Signed-off-by: Alexander Potapenko <glider@google.com>
>>> ---
>>> v2: - if len < sizeof(int), make it 0
>>
>> No, you should signal an error if the len is too small.
> According to manpages, only setsockopt() may return EINVAL.
> Is it ok to change the behavior of getsockopt() to return EINVAL in
> this case? (I.e. won't we break existing users that don't expect it?)

They are currently getting corrupt data depending upon the endianness,
so -EINVAL is a serious improvement.
