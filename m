From: Patrick McHardy <kaber@trash.net>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Mon, 08 Nov 2004 17:12:00 +0100
Message-ID: <418F9AD0.1040701@trash.net>
References: <418B4C7C.8000402@crocom.com.pl> <418EA032.7050507@trash.net> <418ECE85.9090203@trash.net> <20041108135431.GE31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Szymon Miotk <spam@crocom.com.pl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041108135431.GE31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>>+	/* unlink inner qdiscs from dev->qdisc_list immediately */
>>+	if (qdisc->ops->cl_ops != NULL)
>>+		list_add(&qdisc->list, &cql);
>>    
>>
>
>I think you should extend the above to:
>
>if (qdisc->ops->cl_ops != NULL && !list_empty(&qdisc->list))
>
>Otherwise you might unlink entries just added before the
>rcu callback and it prevents an unneeded attempt to delete
>qdiscs for inner classful qdiscs
>  
>
There is some optimization possible, I will do this for the final
patch. But I don't understand the problem you refer to, can you
please explain ?

Regards
Patrick
