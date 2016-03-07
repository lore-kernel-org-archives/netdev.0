From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v4 net-next 8/9] net: add a hardware buffer management helper API
Date: Mon, 07 Mar 2016 09:15:53 +0100
Message-ID: <87pov666va.fsf@free-electrons.com>
References: <1457217507-10778-1-git-send-email-gregory.clement@free-electrons.com>
	<1457217507-10778-9-git-send-email-gregory.clement@free-electrons.com>
	<CAPv3WKeTGy+HfG=vyY04xi4Spy6eUTF_LX_X=V0=ZAGhxURdJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Timor Kardashov <timork@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKeTGy+HfG=vyY04xi4Spy6eUTF_LX_X=V0=ZAGhxURdJg@mail.gmail.com>
	(Marcin Wojtas's message of "Sun, 6 Mar 2016 20:21:51 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
 
 On dim., mars 06 2016, Marcin Wojtas <mw@semihalf.com> wrote:

> Hi Gregory,
>
>
>> +int hwbm_pool_add(struct hwbm_pool *bm_pool, unsigned int buf_num, gfp_t gfp)
>> +{
>> +       int err, i;
>> +       unsigned long flags;
>> +
>> +       spin_lock_irqsave(&bm_pool->lock, flags);
>> +       if (bm_pool->buf_num == bm_pool->size) {
>
> 'size' field is used as a 'frag_size' but here it means pool capacity.
> I think it's better to keep 'size' for pool capacity and add
> 'buf_size' field to struct hwbm_pool.


I thought I already added this field, but it seems that I didn't so. So
I will add it.

>
>> +               pr_warn("pool already filled\n");
>> +               return bm_pool->buf_num;
>> +       }
>> +
>> +       if (buf_num + bm_pool->buf_num > bm_pool->size) {
>> +               pr_warn("cannot allocate %d buffers for pool\n",
>> +                       buf_num);
>> +               return 0;
>> +       }
>> +
>> +       if ((buf_num + bm_pool->buf_num) < bm_pool->buf_num) {
>
> What is a point of this condition? How possibly after checking if
> capacity of pool is not exceeded, this one would ever be true?

see http://thread.gmane.org/gmane.linux.kernel/2125152/focus=2137421

this test is here to ensure that (buf_num + bm_pool->buf_nu doesn't
wrap.

Thanks,

Gregory

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
