From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Thu, 6 Nov 2003 11:59:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031106115935.0cd56745.davem@redhat.com>
References: <OF5A6B1679.D88C275D-ON88256DD6.006CF971@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OF5A6B1679.D88C275D-ON88256DD6.006CF971@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 6 Nov 2003 11:58:24 -0800
Krishna Kumar <kumarkr@us.ibm.com> wrote:

> When unregister_netdev() is called by the driver, it first calls
> unregister_netdevice() which
> drops it's last ref to the dev, making it zero. unregister_netdev() then
> calls rtnl_unlock() which
> calls netdev_run_todo(), which calls netdev_wait_allrefs() and only after
> that succeeds,
> does the driver do a free_netdev(). So the dev should not be freed while
> the wait_ref() is
> executing, and the original code looks correct.

That's correct.

> I don't know if it is some corruption on my system, some hardware problem ?
> I will look
> some more, also try to get a different machine.

It could be some 'user after free' or similar issue.
Just an idea of something else to look for.

My earlier comments about "putting to zero multiple times" were
misguided, I forgot that these days dev_put() just decrements the
count and does not do anything special when the count reaches zero.
