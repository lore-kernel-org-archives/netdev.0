From: Paul Moore <paul.moore@hp.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Tue, 20 Jan 2009 15:47:44 -0500
Message-ID: <200901201547.44981.paul.moore@hp.com>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-security-module" <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Stephan Peijnik <stephan@peijnik.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1232473719.24943.102.camel@sp-laptop3.sp-local>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 January 2009 12:48:39 pm Stephan Peijnik wrote:
> All proposed implementations of personal firewalls until now have
> made it rather clear that the decision-making logic should be placed
> in userspace, whilst only a small piece of code communicating with a
> userspace daemon should be placed in the kernel itself.
>
> Okay, enough of the (not so) brief description on what people want to
> do and on to a summary of what has been discussed so far.
>
> Most implementations started out using the LSM framework for creating
> a personal firewall, that's also the reason the whole discussion
> started out on the LSM mailing list.
> Even though this looks like a good solution there is one main problem
> with the LSM framework right now: only a single LSM module can be
> loaded and enabled at a time.

...

> Another approach that has been suggested is using the netfilter
> framework for this purpose. Even though this again sounds like a good
> idea in the first place it also has its flaws.

...

> And yet another approach was suggested: hooking socket-related calls
> directly in net/socket.c. This would mean that the personal firewall
> code is called directly from net/socket.c and can this way work in
> process-context, without using the LSM framework.

Another option that was brought up (although perhaps not very clearly 
since it isn't listed here) was the embedding of the personal firewall 
hooks into the individual LSMs roughly similar to how capabilities are 
handled with SELinux today (a separate security mechanism that has 
explicit calls within SELinux).  This approach enables the use of 
current LSMs (although minor modifications will be needed) and avoids 
the need to add new hooks to the core network stack.

> What has not been agreed on yet is whether only a way of hooking
> these calls should be made available to implementations or whether
> the whole in-kernel part should be developed together and allow
> implementations of personal firewalls in userspace only, for example
> using a netlink socket to communicate with the shared in-kernel code.

Since there will always be a significant userspace component to any 
personal firewall approach it seems reasonable to push the decision 
making into userspace and leave the kernel component relatively simple.  
The basic idea behind Samir's "snet" concept where the kernel simply 
passes messages to userspace and waits for a verdict seems like a 
reasonable approach in that it can be made to support different 
personal firewall implementations/designs without significant changes 
to the kernel.

-- 
paul moore
linux @ hp
