From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sun, 07 Nov 2004 17:19:58 +0100
Message-ID: <418E4B2E.1070407@trash.net>
References: <20041105163951.GY12289@postel.suug.ch> <418BB7D2.6060908@trash.net> <20041105175812.GZ12289@postel.suug.ch> <418BC40E.8080402@trash.net> <20041105194303.GA12289@postel.suug.ch> <20041106011843.GI12289@postel.suug.ch> <418C2D40.9020300@trash.net> <20041106015931.GA28715@postel.suug.ch> <20041106145036.GB28715@postel.suug.ch> <418DE37E.2050504@trash.net> <20041107140015.GA31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041107140015.GA31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>You mean before qdisc_lookup and until the reference is released
>again? These are huge locking regions involving calls which might
>sleep and possible qdisc_destroy calling paths.  So this won't
>work quite well.
>
Who cares about huge sections while holding reference counts ?
qdisc_destroy won't destroy the qdisc until all references have
been dropped, that's the whole point of it.

>So in my opinion we should screw that call_rcu because it doesn't
>make much sense. In case dev_activate is not synchronized with
>rtnl sempaphore we have to make sure that qdisc_destroy always
>locks on qdisc_tree_lock which is not the case for a few paths as
>of now, although I'm not sure if any of those actually ever call
>qdisc_destroy with refcnt==1.
>  
>
I'm also fixing up the remaining locking bugs, so before we start
reverting things lets just wait and see how it gets.

Regards
Patrick
