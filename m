From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Use CAP_NET_ADMIN and alias netdev-nlmon instead
Date: Sat, 09 Aug 2014 21:32:18 +0200
Message-ID: <53E67742.9080405@redhat.com>
References: <7B1A5F4E-7DCD-4054-9E8C-E5511AF64CE3@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069AbaHITcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Aug 2014 15:32:24 -0400
In-Reply-To: <7B1A5F4E-7DCD-4054-9E8C-E5511AF64CE3@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2014 11:22 PM, Marcel Holtmann wrote:
> Hi,
>
> so I am running this command sequence:
>
> 	ip link add name nlmon type nlmon
> 	ip link set dev nlmon up
>
> With that I get this message in dmesg:
>
> Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).
 > Use CAP_NET_ADMIN and alias netdev-nlmon instead.
>
> The kernel section producing this is dev_load() from net/core/dev_ioctl.c:
>
>          no_module = !dev;
>          if (no_module && capable(CAP_NET_ADMIN))
>                  no_module = request_module("netdev-%s", name);
>          if (no_module && capable(CAP_SYS_MODULE)) {
>                  if (!request_module("%s", name))
>                          pr_warn("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
>                                  name);
>          }
>
> Since I am explicitly giving the name from userspace, I have no idea why the
 > kernel bugs me in providing netdev-nlmon alias. It makes no sense to me. What
 > is the reasoning behind this?

Could it just be that your process doesn't have CAP_NET_ADMIN set
but CAP_SYS_MODULE instead thus triggering this pr_warn()?

  grep Cap /proc/$$/status ?

Hm, I don't think this is nlmon related, above works fine on my side.
