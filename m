From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] neighbour tables configuration via rtnetlink
Date: 07 Mar 2005 08:34:59 -0500
Message-ID: <1110202499.1094.1371.camel@jzny.localdomain>
References: <20050305172257.GN31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050305172257.GN31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-03-05 at 12:22, Thomas Graf wrote:
> Hi,
> 
> I have need to change multiple neighbour table parameters as a atomic operation

The patch overall looks ok although adventerous.
What is it that requires you to change multiple parameters atomically? I
cant seem to think of anything. I can see value in seeing some of these
parameters in user space. Maybe.

> which lead me to make it available via rtnetlink. I started with the patch
> below which extends the existing RTM_*NEIGH commands by a flag NTF_TABLES
> changing the context from entries to the tables itself. I regard this as quite
> hacky, the alternative would be to add a new RTM operation set, i.e.
> RTM_*NEIGHTBL or alike.
> 
> It's only dumping for now but I plan to also allow modification of parameters.

Some of the parameters you are dumping maybe dangerous if they are also
allowed to be setable. As an example, changing a table name/id etc.
I think you should review closely again what needs to be exposed.

> One of the problem that arises is the fact that the interface identifier,
> to differ the various parameters sets, is stored in the sysctl table which
> would introduce quite a nasty depedency.
> 
> Before I go ahead, putting more effort into it, what is our preferred
> interface for network configuration? My personal preference is to make
> everything available via netlink 

I think this is reasonable. However - it is a lot of work. I will have
no issues with seeing nothing else but netlink (even for ethtool like
setups). There are certain things that would require more attention than
others. I was going to write a simple patch to allow setting of indev
parameters via netlink but havent had time. Started it but havent had
time to revisit it - if you want to take over that one as well i could
pass it on to you.

> with the long term plan to extend it with distributive remote configuration 
> protocol in userspace. 

Related but slightly different issues.
To achieve distributed configuration you dont need netlink. The main
advantage of netlink over say /proc is the ability to do async events.
[Yes, I know i have been shouting for taking netlink and and sending it
over the wire and mucking around with endianness flags - but after
practical considerations i am having second thoughts;] 

> If so,
> shall we continue to push everything into rtnetlink regardless of the
> association to routing? The only drawback of the currently "overloaded"
> rtnetlink is the rtnl semaphore which has grown into something like
> the BKL for networking. I'm not aware of any performance problems or
> other issues because of this except for the module loading over nfs.
> Does anyone?
> 

You need rtnetlink for anything that has "interface" relationship
because for those you end up using the rtnl semaphore. So you are stuck
for all the ones that somehow in their configuration the term "dev" may
appear.


cheers,
jamal
