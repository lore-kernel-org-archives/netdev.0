From: Patrick McHardy <kaber@trash.net>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 02:29:47 +0100
Message-ID: <41916F0B.5010809@trash.net>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041110012251.GK31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>* Patrick McHardy <41916A91.3080107@trash.net> 2004-11-10 02:10
>  
>
>>Can you please show an example of a case where this is needed ?
>>Just to help me understand.
>>    
>>
>
>The action code might load modules in the middle of a classifier
>configuration and it will be very hard to reverse those changes.
>Right now we could move it to the top of all configurations and it
>would probably be possible to get back where we fetch the device
>but it will get impossible once a classifier requires module
>loading which is not unlikely.
>  
>
Assuming all error-paths do proper cleanup, returning -EAGAIN
should always result in the same configuration state as before.
Module-loading as a side-effect is exactly why this is done,
the replay will have all modules available.

>Well, it's not impossible but it would mean to have the action
>code parse the TLV and just try to load the module, then report
>to the classifier so it can try to load its own modules and then do
>the actual action and classifier configuration. I don't even want to
>think of how nasty it gets once a action module requests modules itself ;->
>  
>
I still don't understand the problem.

Regards
Patrick
