From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] bluetooth: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Mon, 18 Mar 2013 11:13:36 -0700
Message-ID: <1363630416.2074.25.camel@joe-AO722>
References: <1363111995-26866-1-git-send-email-silviupopescu1990@gmail.com>
	 <20130313.053145.2200448840921851390.davem@davemloft.net>
	 <CAPWTe+JzznuWYKksAfxkD=u9kv8DuAF4v2AWVxd2OUeDtCYKBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Silviu Popescu <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPWTe+JzznuWYKksAfxkD=u9kv8DuAF4v2AWVxd2OUeDtCYKBA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-03-18 at 20:05 +0200, Silviu Popescu wrote:
> On Wed, Mar 13, 2013 at 11:31 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> > From: Silviu-Mihai Popescu <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date: Tue, 12 Mar 2013 20:13:15 +0200
> >
> >> @@ -590,10 +590,7 @@ int __init bt_sysfs_init(void)
> >>       bt_debugfs = debugfs_create_dir("bluetooth", NULL);
> >>
> >>       bt_class = class_create(THIS_MODULE, "bluetooth");
> >> -     if (IS_ERR(bt_class))
> >> -             return PTR_ERR(bt_class);
> >> -
> >> -     return 0;
> >> +     return PTR_RET(bt_class)
> >
> > Don't bother submitting patches you aren't even going to try
> > to compile.
> >
> > I'm rejecting all of your current submissions.  Resubmit them
> > when you feel like typing 'make' from time to time.
> >
> >
> 
> Sorry for the trouble caused and sorry for the late reply.
> That being said, I'd like to understand a bit better what exactly I messed up.
> I've just pulled the latest revision of the mainline kernel and made
> the changes in this patch.
> I've tried with make defconfig (which would be x86_64_defconfig in my
> case), followed by
> make menuconfig to select the bluetooth options and make allyesconfig.
> Both defconfig and allyesconfig compile successfully on my system.
> Would you be so kind as to tell me what error you have encountered?
> Or perhaps enlighten me as to what I'm still doing wrong. I'd like to
> learn from my mistakes.

You do have to ensure that the file you modify
is actually compiled.

Sometimes it's easier to type make path/file.o

In any case, this is missing the statement terminating
semicolon after PTR_RET(bt_class).
