From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Mon, 15 Jun 2009 12:00:35 +0900
Message-ID: <20090615120035.a8b7b38f.usui@mxm.nes.nec.co.jp>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	<20090611.021347.142243970.davem@davemloft.net>
	<20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>
	<6599ad830906112206n745fb0dw19cdb75d7c40b2a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830906112206n745fb0dw19cdb75d7c40b2a4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi, Paul.

Thank you for your advice.

On Thu, 11 Jun 2009 22:06:00 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Thu, Jun 11, 2009 at 8:40 PM, Minoru Usui<usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> >
> > It's true. If my patch applied, old syntax can't use.
> > But I think compatibility is important, too.
> > So I'll make a new patch which can use both old and new syntax, when we write classid to net_cls.classid file.
> >
> > Present implementation is an asymmetry with read and write.(read: decimal, write: hexadecimal)
> 
> You can write the classid value in decimal too, or even octal - it
> just uses strtoull() to convert the string to an integer, so
> 0x-prefixed hex values are handled automatically.
> 
> >
> > If it's ok, I'd like to be able to use tc syntax(X:Y style),
> > because cls_cgroup's purpose is select class which create by tc command.
> > tc command can only use classid syntax X:Y style, so we should be able to use X:Y style to cls_cgroup.
> 
> We should keep it as it is - purely apart from compatibility issues,
> there's no need to introduce the complexity of the tc interface into
> the cls_cgroup kernel code. When a cgroup control file represents a
> simple integer, then it should be exposed as such.

I understand your opinion.
You mean, kernel I/F should be simple, so we should use the same format as the kernel.
I completely agree.

Actually, In tc <-> kernel I/F (which uses netlink), tc sets classid to hexadecimal style not X:Y style.
X:Y style is result of translating by tc command.

I thought this patch was very useful at first, but it's not necessary to implementing to the kernel.
This function can be implemented on user space if we need.
And we can also keep compatibility of net_cls.classid I/F. :-)

I drop this patch. I'm sorry for confusing a lot of people.
-- 
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
