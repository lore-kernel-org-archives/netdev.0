From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-next PATCH v4 0/3] net: reserve ports for applications using fixed port
Date: Tue, 16 Feb 2010 10:49:37 -0800
Message-ID: <m17hqd583i.fsf@fess.ebiederm.org>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com>
	<m1sk916qkv.fsf@fess.ebiederm.org>
	<201002162004.33533.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002162004.33533.opurdila@ixiacom.com> (Octavian Purdila's message of "Tue\, 16 Feb 2010 20\:04\:33 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Octavian Purdila <opurdila@ixiacom.com> writes:

> Hi Eric, thanks for going over this.
>
> The use case (large bitmaps/lists) is different enough from what we have today 
> (small bitmaps) and that is why I think that we need this new interface. 
>
> If I get bitmap_parse_user correctly, for a 64k bitmap it expects a 2K comma 
> separated values. That is not the most intuitively way for the user to set a 
> list of ports he wants to reserve. 

In this case I expect an interface of comma separated ranges would be
ideal.  Typically compact, and modifiable by writing the new value to
the file.

I think the default value would be something like 32768-61000.

> Using 64K files has the same practical issues (the user would have to cat all 
> 64K files to determine which ports are reserved) plus it has issues caused by 
> the large number of files: significant memory overhead and also significant time 
> for registering those files.

"grep -l 1 *" isn't particularly difficult, and it would be one sysctl registration
call.  It is true that the sysctl memory footprint would be a pain in that case.

Eric
