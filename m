From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Extend netlink error codes
Date: Sat, 11 Sep 2004 18:24:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911162433.GC21181@postel.suug.ch>
References: <20040910225158.GO20088@postel.suug.ch> <20040911155839.GN4431@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040911155839.GN4431@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Andi Kleen <20040911155839.GN4431@wotan.suse.de> 2004-09-11 17:58
> IMHO it would be far better to just pass text errors
> in a variable length packet back.  It's a bit plan9ish,
> but it would work nicely here and be a bit improvement
> (especially for the qdiscs) 

I had the same idea and the only good way to do so would
be to add a char * errbuf or alike to struct netlink_opt
and access it via skb.sk.sk_protinfo.

The bad side is that the for example cls and sch api don't
provide the skb to the implementing modules and therefore
they can't access the error buffer. I don't want to change
all netlink users because of this.

Changing all paths back to netlink_ack to provide a struct
containing the errno and an additional text error buffer is
no option for me either.

Correct me if I'm wrong.

> Otherwise you will end up with a mainteance nightmare of a
> long list of error codes that needs to be updated for every new
> subsystem.

I would suggst to split them up and assign blocks of free codes
to subsystems.

> And everybody who has a patch to add a new netlink
> user would always fight with conflicts in this file.

This is indeed a problem.

> I don't think an very specific error like
> "CFQ subsystem parameter X is FOO, can be only upto BAR" 
> can be nicely put into a global error file.

True, I would really like to have such error messages.
