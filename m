From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: net_cls: fd passed in SCM_RIGHTS datagram not set
 correctly
Date: Mon, 21 Jan 2013 17:54:32 +0800
Message-ID: <50FD1058.2000306@huawei.com>
References: <1358761102-7765-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358761102-7765-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2013/1/21 17:38, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> 
> Commit 6a328d8c6f03501657ad580f6f98bf9a42583ff7 changed the update
> logic for the socket but it does not update the SCM_RIGHTS update
> as well. This patch is based on the net_prio fix commit
> 
> 48a87cc26c13b68f6cce4e9d769fcb17a6b3e4b8
> 
>     net: netprio: fd passed in SCM_RIGHTS datagram not set correctly
> 
>     A socket fd passed in a SCM_RIGHTS datagram was not getting
>     updated with the new tasks cgrp prioidx. This leaves IO on
>     the socket tagged with the old tasks priority.
> 
>     To fix this add a check in the scm recvmsg path to update the
>     sock cgrp prioidx with the new tasks value.
> 
> Let's apply the same fix for net_cls.
> 
> Reported-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Acutally I didn't report this. I was about to send exactly the same
patch and then I noticed the shared socket issue. ;)

> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  net/core/scm.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
