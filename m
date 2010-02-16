From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v4 1/3] sysctl: refactor integer handling proc code
Date: Tue, 16 Feb 2010 13:41:56 +0200
Message-ID: <201002161341.56206.opurdila@ixiacom.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <1266271241-6293-2-git-send-email-opurdila@ixiacom.com> <4B7A5A23.3080309@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:27930 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753929Ab0BPLp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 06:45:58 -0500
In-Reply-To: <4B7A5A23.3080309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 February 2010 10:41:07 you wrote:

> > +static int proc_skip_wspace(char __user **buf, size_t *size)
> > +{
> > +     char c;
> > +
> > +     while (*size) {
> > +             if (get_user(c, *buf))
> > +                     return -EFAULT;
> > +             if (!isspace(c))
> > +                     break;
> > +             (*size)--; (*buf)++;
> > +     }
> > +
> > +     return 0;
> > +}
> 
> In lib/string.c we have skip_spaces(), I think we can use it
> here instead of inventing another one.
> 

I'm afraid we can't, skip_spaces does not accept userspace buffers.
