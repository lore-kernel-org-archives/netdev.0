From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/11] [NET] Convert sk_zapped into SOCK_ZAPPED flag
Date: Wed, 09 Mar 2005 21:05:50 +0100
Message-ID: <422F571E.2020708@trash.net>
References: <20050309194521.GH31837@postel.suug.ch> <20050309194711.GJ31837@postel.suug.ch> <422F5461.4080008@trash.net> <20050309195649.GT31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050309195649.GT31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <422F5461.4080008@trash.net> 2005-03-09 20:54
>>
>>What about volatile ? sock_set_flag() uses __set_bit(), so its not
>>the same.
> 
> 
> I thought about this for a while but couldn't find a reason
> why it shouldn't work. Actually I don't even see any reason for
> having sk_zapped be volatile.

You're probably right. I believe this piece of code from 2.4 is the
reason for it beeing volatile:

#ifdef TCP_DEBUG
         if (sk->zapped) {
                 printk(KERN_DEBUG "TCP: double destroy sk=%p\n", sk);
                 sock_hold(sk);
         }
         sk->zapped = 1;
#endif

Regards
Patrick
