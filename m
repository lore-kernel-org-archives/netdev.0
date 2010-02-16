From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v4 1/3] sysctl: refactor integer handling proc code
Date: Tue, 16 Feb 2010 15:44:33 +0200
Message-ID: <201002161544.33086.opurdila@ixiacom.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <201002161341.56206.opurdila@ixiacom.com> <4B7A991F.3040601@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7A991F.3040601@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 16 February 2010 15:09:51 you wrote:
> Octavian Purdila wrote:
> > On Tuesday 16 February 2010 10:41:07 you wrote:
> >>> +static int proc_skip_wspace(char __user **buf, size_t *size)
> >>> +{
> >>> +     char c;
> >>> +
> >>> +     while (*size) {
> >>> +             if (get_user(c, *buf))
> >>> +                     return -EFAULT;
> >>> +             if (!isspace(c))
> >>> +                     break;
> >>> +             (*size)--; (*buf)++;
> >>> +     }
> >>> +
> >>> +     return 0;
> >>> +}
> >>
> >> In lib/string.c we have skip_spaces(), I think we can use it
> >> here instead of inventing another one.
> >
> > I'm afraid we can't, skip_spaces does not accept userspace buffers.
> 
> Well, you need to use copy_from_user() before call it.
> 

And how much would you copy? You need to either use a stack buffer and do a 
loop copy or you would need to copy the whole userspace buffer which means we 
need to allocate a kernel buffer. I think its much cleaner the way is currently 
done.
