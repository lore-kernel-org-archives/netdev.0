From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6 NET] Fixes slab corruption in cbq_destroy
Date: Thu, 16 Sep 2004 16:58:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4149AA12.10306@trash.net>
References: <20040916132856.GA27293@postel.suug.ch> <4149998C.6060501@trash.net> <20040916140943.GC27293@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040916140943.GC27293@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>* Patrick McHardy <4149998C.6060501@trash.net> 2004-09-16 15:47
>  
>
>>I don't see how there can be slab corruption. qdisc_put_rtab only
>>calls kfree if the table is found in qdisc_rtab_list, which only
>>happens once. But the patch is still fine as cleanup :)
>>    
>>
>
>On second call to qdisc_put_rtab with tab pointing to an already
>freed qdisc_rate_table:
>
>sch_api.c:271:  if (!tab || --tab->refcnt)
>  
>
You're right, no double free but accessing and modifying of freed memory.

Regards
Patrick
