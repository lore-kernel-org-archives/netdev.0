From: Shea Levy <shea@shealevy.com>
Subject: Re: Hang with "runaway loop modprobe net-pf-1" on Linux 3.0.4
Date: Sat, 01 Oct 2011 16:37:54 -0400
Message-ID: <4E877A22.6070605@shealevy.com>
References: <7ca3debde28dcc206c1f6f787df5c619.squirrel@webmail.shealevy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Alban Crequy" <alban.crequy@collabora.co.uk>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Davide Libenzi" <davidel@xmailserver.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:39307 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754908Ab1JAUiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2011 16:38:11 -0400
Received: from homiemail-a80.g.dreamhost.com (caibbdcaaaaf.dreamhost.com [208.113.200.5])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 1D3A91844DE
	for <netdev@vger.kernel.org>; Sat,  1 Oct 2011 13:38:10 -0700 (PDT)
In-Reply-To: <7ca3debde28dcc206c1f6f787df5c619.squirrel@webmail.shealevy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2011 08:38 AM, shea@shealevy.com wrote:
> Hello,
>
> My initrd mounts /proc and /sys, puts a tmpfs at /dev, then loads ext4. On
> 2.6.39 (and earlier), this works fine and the initrd init continues
> happily. On 3.0.4, however, the kernel spits out
>
>> request_module: runaway loop modprobe net-pf-1
> a few times then hangs. If I drop into a shell before loading ext4 and run
> modprobe unix, the same problem occurs. The modprobe used is dynamically
> linked with glibc (which is included in the initrd), and it is the same
> modprobe on the working and non-working systems. From my searches, it
> appears that CONFIG_UNIX=y instead of =m would probably solve this
> problem, but I'd rather keep it as a module if it's possible to get it
> working. What's going wrong here? Why does it work on 2.6.39 but not
> 3.0.4?
>
> Regards,
> Shea Levy
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

CC'ing af_unix.c maintainers. Also, I had the same problem with 3.0.
