From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 15:52:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D1F687.6030307@pobox.com>
References: <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <20040617185605.GA32216@bougret.hpl.hp.com> <40D1EC54.8000904@pobox.com> <20040617193154.GE32216@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040617193154.GE32216@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> 	And guess what, I'm helping you in the process. Look back at
> all the e-mail I sent to the various thread on the subject, and you
> will clearly see that I'm constructive and giving suggestion on how to
> do best in this process. I even provide patches.
> 	I don't understand why you are so opposed to my suggestions,
> and what more you expect from me.
[...]
> 	Converging wireless into Linux since 1996. Welcome to the club ;-)

hehe  :)

I'm _not_ blaming you for anything.  You have certainly contributed a 
lot.  I've enjoyed working with you in the past, today, and hopefully 
into the future as well.  I _am_ listening.  But I think we have a 
fundamental disagreement:

I feel strongly (as you see :)) that the type-opaque interface has got 
to go, and that means breaking backwards compatibility in the driver API.

The iw_handler interface breaks rules of C that we shouldn't be 
breaking.  Today's kernel includes boatloads of reference-counted 
kobjects, with strict definitions of lifetime rules.  This has exposed 
endless bugs and caused a lot of pain, but overall it's a good thing to 
clean all that up.  Interfaces that store offsets into driver-local 
structures (iw_handler_def) violate these lifetime rules by simply 
assuming you always have access to the structure of choice.

We want to design driver interfaces that make it tough for the driver 
writer to screw up.  Excluding yourself, myself, and others on this 
list, I think we all know that driver writers can't code their way out 
of a paper bag.  A properly designed interface lets the compiler flag 
incorrect code at the first possible opportunity.  Current WE __does__ 
get the job done (kudos), but it simply doesn't afford that kind of 
protection.

	Jeff
