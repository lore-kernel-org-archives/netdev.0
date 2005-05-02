From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Mon, 02 May 2005 08:10:38 -0400
Message-ID: <1115035838.8929.236.camel@localhost.localdomain>
References: <1114879817.8929.117.camel@localhost.localdomain>
	 <4273BB30.1050402@trash.net> <4273BBAA.6060405@trash.net>
	 <1114882045.8929.123.camel@localhost.localdomain>
	 <4273CAB7.6080403@trash.net>
	 <1114890709.8929.147.camel@localhost.localdomain>
	 <20050430200848.GF577@postel.suug.ch>
	 <1114894202.8929.165.camel@localhost.localdomain>
	 <20050430215550.GH577@postel.suug.ch>
	 <1114900485.8929.171.camel@localhost.localdomain>
	 <20050430235809.GI577@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050430235809.GI577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-05 at 01:58 +0200, Thomas Graf wrote:
> * jamal <1114900485.8929.171.camel@localhost.localdomain> 2005-04-30 18:34
[..] 
> > Perhaps we can reuse classid by flagging somewhere? 
> > A good place to do it is tc_verdict. There a few bits still left.
> > We could set a bit to say the meaning of classid to be global vs local.
> 
> Sounds good to me, I'm not quite sure if I still have a good enough
> picture of your action code. Let's assume we have ematches and an
> action setting the classid at ingress. The action sets the above flag
> to state the global scope.

Which means the classid is not reset by exec().

>  The packet passes the stack and the
> classid gets copied into the new encapsulated packet. On the egress
> device we have something like a nop action assigning the classid
> to res->classid. How do we make sure that the classid remains
> untouched even if the packet passes a dummy device in between having
> actions configured? Can we we still have functional actions on
> this dummy device?

I would say that if dummy changes it because of a policy, then thats a
fair deal. i.e

filter blah blah \
action add meta classid global :23 

I am beginning to think that perhaps classid should stay as a local
scope metadata and what Patrick suggested maybe the way out. Although i
have to admit I dont like a generic function to have a parameter that
only a very small set of users find useful. If we are going to allow a
structure to be passed back and forth, perhaps it should also carry
other things (in addition to _result). Need to think a little.

cheers,
jamal
