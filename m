From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] meta ematch
Date: Sun, 16 Jan 2005 16:57:58 +0100
Message-ID: <20050116155758.GV26856@postel.suug.ch>
References: <20050110211747.GA26856@postel.suug.ch> <1105394738.1085.63.camel@jzny.localdomain> <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net> <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net> <20050114151407.GR26856@postel.suug.ch> <1105887519.1097.597.camel@jzny.localdomain> <20050116150914.GU26856@postel.suug.ch> <1105889874.1090.613.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105889874.1090.613.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105889874.1090.613.camel@jzny.localdomain> 2005-01-16 10:37
> On Sun, 2005-01-16 at 10:09, Thomas Graf wrote:
> 
> > The lvalue will be TCF_META_ID_INDEV and your rvalue will be
> > TCF_META_TYPE_VAR with "eth0" as payload(TCF_EM_META_RVALUE).
> > TCF_EM_META_LVALUE will be unused in this case.
> 
> ok - i get it. So the rvalue is basically just the data that needs to be
> compared against. rvalue confused me a little. If you had called it
> meta_data i would have got it right away. But now that you explain it,
> makes sense. 

The rvalue may also point to a metadata in the kernel. This gets
useful when comparing dev against real dev or if nfmark, tcindex,
you name it carries a ifindex for example. It would even be possible
to compare two strings from userspace but that wouldn't make sense.
The only difference between lvalue and rvalue is that the lvalue
carries the operand.


> I am not sure iam following yet:
> 
> So in the case of indev, you would need to 
> - get indev ifindex from skb
> - get indev name from skb
> - compare the two??
> 
> Actually it may be a little overkill to have those two as separate
> entities with their own headers etc, no? Why not just store it in the
> same fashion you transported it from/to user space? 

For devices, userspace can choose between comparing indices or
device names. The variable type will get more use once I add
the IPv6 routing meta matches.
