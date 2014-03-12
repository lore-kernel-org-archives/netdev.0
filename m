From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 0/2][V2] net: Implement SO_PEERCGROUP to get cgroup of
 peer
Date: Wed, 12 Mar 2014 13:56:28 -0700
Message-ID: <5320C9FC.6070301@amacapital.net>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394657163-7472-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/12/2014 01:46 PM, Vivek Goyal wrote:
> Hi,
> 
> This is V2 of patches. Fixed the function format issue and also I was using
> CONFIG_CGROUP instead of CONFIG_CGROUPS. That led to crash at boot. Fixed that.
> 
> Some applications like sssd want to know the cgroup of connected peer over
> unix stream socket. They want to use this information to map the cgroup to 
> the container client belongs to and then decide what kind of policies apply
> on the container.
> 

Can you explain what the use case is?

My a priori opinion is that this is a terrible idea.  cgroups are a
nasty interface, and letting knowledge of cgroups leak into the programs
that live in the groups (as opposed to the cgroup manager) seems like a
huge mistake to me.

If you want to know where in the process hierarchy a message sender is,
add *that* and figure out how to fix the races (it shouldn't be that hard).

--Andy
