From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-next PATCH v4 0/3] net: reserve ports for applications using fixed port
Date: Tue, 16 Feb 2010 09:25:04 -0800
Message-ID: <m1sk916qkv.fsf@fess.ebiederm.org>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> (Octavian Purdila's message of "Tue\, 16 Feb 2010 00\:00\:38 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Octavian Purdila <opurdila@ixiacom.com> writes:

> This iteration makes the bitmap dynamically allocated since it is
> quite big (8192 bytes) and adding that much in BSS may still,
> apparently, cause problems on some architectures.
>
>
> Octavian Purdila (3):
>   sysctl: refactor integer handling proc code
>   sysctl: add proc_dobitmap
>   net: reserve ports for applications using fixed port numbers
>

I don't like the /proc interface for this.  That is certainly not the
format I would choose for a bitmap.  The way you have described this
it looks like you are a set of different individual values instead of
one large value.  History says one value per file is the ideal in a
user space facing interface.  Intuitively I would not know how to
change your new proc interface after catting the file.  The classic
read the file tweak the value and write the new value back will not
work.


Also we already have a common function for dealing with bitmaps
in /proc.  bitmap_parse_user.  Used in /proc/irq/NNN/smp_affinity
among other places.

So can you please use bitmap_parse_user, or break this up into
64k individual files that we can set individually?

Eric
