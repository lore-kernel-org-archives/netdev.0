From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Extended Generic Packet Classifier
Date: Fri, 24 Dec 2004 00:09:22 +0100
Message-ID: <20041223230922.GH7884@postel.suug.ch>
References: <20041223194834.GF7884@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20041223194834.GF7884@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20041223194834.GF7884@postel.suug.ch> 2004-12-23 20:48
> 	The patch including the userspace tools can be found at
> http://people.suug.ch/~tgr/egp/. Be warned, this is totally unfinished
> work, some parts are not fully implemented yet it and still contains a lot
> of known issues. Nevertheless, I think it is time to publish it.

A few remarks on the yet to be addressed issues:

 o The evaluation of values when reading one uses a recursive algorithm which
   must be transformed. It's not difficult, just needs to be done.

 o The design decision to transfer the complete configuration in a
   single netlink message was wrong, it sets strong limits on the size
   of configurations. Changing it to a architecture where keys/values can
   be added/changed/remove brings some problems with locking and makes
   validation difficult since the number of values/filters/keys must be
   known when validating a key or value. A good solution would be to
   temporarly disable a classifer while changing it and require the
   first change request to submit all parameters required for validation.

 o The fact that a value can represent a key result introduces a nasty
   endless loop possibility. The key referenced by the value could
   itself again reference the value or another key doing so. There is no
   simple solution for this problem.

Some notes on performance:

   EGP generally is a bit slower than classifiers such as u32 and fw
   if used in the same way. This is easly explainable by the improved
   complexity and the level of abstraction. However, one can reduce the
   number of filters and required matches a lot which in the end gives
   better performance results. OTOH, it might be real performance killer
   if used in a wrong way. 

My thoughts on inclusion and future of this:

 o I think it's a rather bad idea to include this as of now, even if the
   code itself is quite clean. Using the cls api is currently the only
   way but it would definitely be better to replace the cls api with
   something like this. EGP could be used as basis.

 o I'll wait for some comments, given someone is actually interested in
   it and decide what do afterwards. There is quite some stuff in the
   queue postponed over and over such as netlink errors, move sched/
   out of rtnetlink, metamatch, etc. If we're going to do the move outside
   of rtnetlink we could at the same time do fundamental changes to the
   API which would be required to take over some of egp's ideas. It
   might be a step too far for some, but we can give it a few hair cuts
   and shrink it down to what is really needed.

Cheers
