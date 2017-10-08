From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [BUG] stmmac: A possible sleep-in-atomic bug in stmmac_suspend
Date: Sun, 8 Oct 2017 23:13:42 +0800
Message-ID: <6ac71618-c2e5-cba5-0e32-c961961eed20@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to stmmac_main.c, the driver may sleep under a spinlock,
and the function call path is:
stmmac_suspend (acquire the spinlock)
   stmmac_disable_all_queues
     napi_disable
       might_sleep --> may sleep
       msleep --> may sleep

This bug is found by my static analysis tool and my code review.


Thanks,
Jia-Ju Bai
