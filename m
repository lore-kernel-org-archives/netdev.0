From: "Mark Broadbent" <markb@wetlettuce.com>
Subject: Re: Followup to netpoll issues
Date: Mon, 10 Jan 2005 22:03:14 -0000 (GMT)
Message-ID: <35248.82.68.149.65.1105394594.squirrel@webmail.wetlettuce.com>
References: <1105045914.7687.3.camel@tigger>
        <20050107002053.GD27896@electric-eye.fr.zoreil.com>
        <1105128887.3814.20.camel@localhost>
        <20050107231815.GC17317@electric-eye.fr.zoreil.com>
Reply-To: markb@wetlettuce.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: <mpm@selenic.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <romieu@fr.zoreil.com>
In-Reply-To: <20050107231815.GC17317@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Francois Romieu said:
> Mark Broadbent <markb@wetlettuce.com> :
> [...]
>> No need, if netpoll_cleanup is called whilst a retry is pending the tx
>> list lock is taken.  All the references to the netpoll pointer are
>> deleted from the pending list before the lock is released.
>
> I may be a bit dense but:
>
> t0             : tx_retry_wq().queue_delayed_work(tx_wq, &tx_wq_obj,
> HZ/100);
>
> t0 + 10*HZ/1000: tx_retry_wq() is done (it was not fast for sure)
>
> t0 + 20*HZ/1000: netpoll_cleanup() + module removal
>
> t0 + HZ/100    : tx_retry_wq() <- Where are its code and data ?

You logic is correct but I'm positive that netpoll.o is always built into
the kernel image and hence cannot be unloaded.
> [...]

Thanks
Mark



-- 
Mark Broadbent <markb@wetlettuce.com>
Web: http://www.wetlettuce.com
