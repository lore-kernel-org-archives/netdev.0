From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] realtek: rtl8xxxu: Use const init arrays
Date: Sat, 01 Oct 2016 14:53:10 -0400
Message-ID: <wrfj37kf6gvd.fsf@redhat.com>
References: <459bf15427d92cd052fb2fe080438fd97a8a6cd8.1475343483.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <459bf15427d92cd052fb2fe080438fd97a8a6cd8.1475343483.git.joe@perches.com>
        (Joe Perches's message of "Sat, 1 Oct 2016 10:39:25 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:
> Make the init arrays const to reduce data.
>
> $ size drivers/net/wireless/realtek/rtl8xxxu/built-in.o* (allyesconfig: x86-32)
>    text	   data	    bss	    dec	    hex	filename
>   80107	  13651	     58	  93816	  16e78	drivers/net/wireless/realtek/rtl8xxxu/built-in.o.new
>   65303	  28435	     58	  93796	  16e64	drivers/net/wireless/realtek/rtl8xxxu/built-in.o.old
>
> Signed-off-by: Joe Perches <joe@perches.com>

In total you grow the kernel by 20 bytes. You reduce the data segment
substantially while growing the text segment instead.

If any architecture replicates the text segment onto individual numa
nodes, this would actually be a real loss rather than a win. Some archs
used to do this, not sure if they are doing it anymore.

I am not against this patch, but I am not sure it's really a win either.

Jes
